import { expect, mock, test } from 'claude-code/testing'

const WINDOW = 200_000

const BAND = {
  component: 'AbovePrompt',
  props: {
    hasSurvey: false,
    isWorking: false,
    maxRows: 6,
    bodyColumns: 120,
    scroll: { offset: 0, bodyRows: 6 },
    view: {},
  },
} as const

test('the forecast draws on terminal and desktop', async ($, on) => {
  let tokens = 0

  on('session.usage', () => ({
    value: {
      startedAt: 0,
      context: { tokens, window: WINDOW, percent: Math.round((tokens / WINDOW) * 100) },
      rateLimits: [],
    },
  }))
  on('turn.complete', () => ({ text: '' }))
  // The engine's own band: empty.
  on('ui.render', () => ({ type: 'Box' }))

  const turn = async (after: number) => {
    tokens = after
    await $.turn.complete({ answer: '', durationMs: 1, isAborted: false, turnId: `t${after}`, reason: 'answer' })
  }

  await turn(36_100)
  await turn(134_400)

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'token-weather', surface, ...BAND })
    expect((await ui.find({ type: 'Text', text: /☂ Showers/ }))?.props.color).toBe('permission')
    expect(await ui.find({ type: 'Text', text: /^67%$/ })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /^134\.4k \/ 200k$/ })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /^▂▆$/ })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /^▲ \+98\.3k last turn$/ })).toBeDefined()
    await ui.unmount()
  }

  await turn(185_000)
  await turn(40_000)

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'token-weather', surface, ...BAND })
    expect((await ui.find({ type: 'Text', text: /☀ Clear/ }))?.props.color).toBe('warning')
    expect(await ui.find({ type: 'Text', text: /^▂▆█▂$/ })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /^▼ -145k last turn$/ })).toBeDefined()
    await ui.unmount()
  }
})

test('a band mounted before the first response fills in after the turn', async ($, on) => {
  let tokens: number | undefined

  on('session.usage', () => ({
    value: {
      startedAt: 0,
      context: tokens === undefined
        ? { window: WINDOW }
        : { tokens, window: WINDOW, percent: Math.round((tokens / WINDOW) * 100) },
      rateLimits: [],
    },
  }))
  on('turn.complete', () => ({ text: '' }))
  on('ui.render', () => ({ type: 'Box' }))

  for (const surface of ['terminal', 'desktop'] as const) {
    tokens = undefined
    const ui = await $.ui.mount({ plugin: 'token-weather', surface, ...BAND })
    expect(await ui.find({ type: 'Text', text: /%$/ })).toBeUndefined()

    tokens = 21_000
    await $.turn.complete({ answer: '', durationMs: 1, isAborted: false, turnId: `first-${surface}`, reason: 'answer' })
    expect(await ui.find({ type: 'Text', text: /^11%$/ })).toBeDefined()
    await ui.unmount()
  }
})

test('/token-weather hides and shows the band', async ($, on) => {
  mock.store(on)
  on('session.usage', () => ({
    value: { startedAt: 0, context: { tokens: 21_000, window: WINDOW, percent: 11 }, rateLimits: [] },
  }))
  on('ui.render', () => ({ type: 'Box' }))

  const run = (args: string) => $.command.run({ command: 'token-weather', args })

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'token-weather', surface, ...BAND })
    expect(await ui.find({ type: 'Text', text: /^11%$/ })).toBeDefined()

    expect((await run('hide')).text).toMatch(/hidden/)
    expect(await ui.find({ type: 'Text', text: /^11%$/ })).toBeUndefined()

    expect((await run('show')).text).toMatch(/shown/)
    expect(await ui.find({ type: 'Text', text: /^11%$/ })).toBeDefined()

    await run('')
    expect(await ui.find({ type: 'Text', text: /^11%$/ })).toBeUndefined()
    await run('')
    expect(await ui.find({ type: 'Text', text: /^11%$/ })).toBeDefined()

    expect((await run('maybe')).text).toMatch(/^Usage:/)
    await ui.unmount()
  }

})

test('a hidden band stays hidden in the next session', async ($, on) => {
  mock.store(on, { isHidden: true })
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  on('session.usage', () => ({
    value: { startedAt: 0, context: { tokens: 21_000, window: WINDOW, percent: 11 }, rateLimits: [] },
  }))
  on('ui.render', () => ({ type: 'Box' }))

  await $.session.start({ cwd: '/', surface: 'desktop', isInteractive: true })

  const ui = await $.ui.mount({ plugin: 'token-weather', surface: 'desktop', ...BAND })
  expect(await ui.find({ type: 'Text', text: /^11%$/ })).toBeUndefined()
  await ui.unmount()
})
