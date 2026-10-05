import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Samples } from '../types'

// Context tokens after each main-loop turn; one more than the chart shows,
// so the oldest bar still has a turn before it.
const samples = atom({ plugin: 'token-weather', key: 'samples' } as const, [] as Samples)
// Context tokens before the first sampled turn: 0 in a fresh session.
const baseline = atom({ plugin: 'token-weather', key: 'baseline' } as const, 0)
// Set by /token-weather hide|show; kept in $.store so it outlives the session.
const isHidden = atom({ plugin: 'token-weather', key: 'isHidden' } as const, false)

const COMMAND = 'token-weather'

const CHART_TURNS = 12
const BARS = '▁▂▃▄▅▆▇█'

// Colors are theme keys, so each light and dark theme picks its own shade:
// warning is a dark gold on light backgrounds and a bright yellow on dark ones.
const FORECAST = [
  { below: 25, icon: '☀', word: 'Clear', color: 'warning' },
  { below: 50, icon: '☁', word: 'Cloudy', color: 'planMode' },
  { below: 75, icon: '☂', word: 'Showers', color: 'permission' },
  { below: 90, icon: '☇', word: 'Storm', color: 'autoAccept' },
  { below: Infinity, icon: '↯', word: 'Compact soon', color: 'error' },
] as const

const forecast = (percent: number) => FORECAST.find(f => percent < f.below) ?? FORECAST[4]

const oneDecimal = (n: number) => n.toFixed(1).replace(/\.0$/, '')

// 850, 98.3k, 200k, 1M
const formatTokens = (n: number) => {
  if (n >= 999_950) {
    return `${oneDecimal(n / 1_000_000)}M`
  }

  return n >= 1000 ? `${oneDecimal(n / 1000)}k` : String(n)
}

const sparkline = (turns: Samples, window: number) =>
  turns
    .map(tokens => BARS[Math.min(BARS.length - 1, Math.floor((tokens / window) * BARS.length))])
    .join('')

const lastTurnDelta = (turns: Samples, before: number) => {
  const last = turns.at(-1)

  if (last === undefined) {
    return null
  }

  return last - (turns.at(-2) ?? before)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const result = await next(e)

    const stored = await $.store.get('isHidden')

    if (typeof stored === 'boolean') {
      await update($, isHidden, () => stored)
    }

    // A reload runs this again: keep the history it already has.
    if ((await read($, samples)).length === 0) {
      const { context } = await $.session.usage()
      await update($, baseline, () => context.tokens ?? 0)
    }

    await $.command.register({
      name: COMMAND,
      description: 'Show or hide the context forecast above the prompt',
      argumentHint: 'show | hide',
      immediate: true,
    })

    return result
  })

  on('session.end', async ($, e, next) => {
    if (e.reason === 'clear') {
      await update($, samples, () => [])
      await update($, baseline, () => 0)
    }

    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)

    // Subagent turns run in their own window.
    if (e.agentId !== undefined) {
      return result
    }

    const { context } = await $.session.usage()
    const tokens = context.tokens

    if (tokens !== undefined) {
      await update($, samples, turns => [...turns, tokens].slice(-(CHART_TURNS + 1)))
    }

    return result
  })

  on('command.run', { command: COMMAND }, async ($, e) => {
    const word = e.args.trim().toLowerCase()

    if (word !== '' && word !== 'show' && word !== 'hide') {
      return { text: `Usage: /${COMMAND} [show | hide]` }
    }

    const hide = word === '' ? !(await read($, isHidden)) : word === 'hide'
    await update($, isHidden, () => hide)
    await $.store.set('isHidden', hide)

    return {
      text: hide
        ? `Token weather hidden. /${COMMAND} show brings it back.`
        : 'Token weather shown above the prompt.',
    }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    // Read before any early return: the reads subscribe this drawing, so the
    // turn that writes samples redraws it. The desktop redraws only then; a
    // band first drawn before any response would otherwise stay empty.
    const turns = await read($, samples)
    const before = await read($, baseline)

    if (await read($, isHidden)) {
      return next(e)
    }

    if (e.props.hasSurvey) {
      return next(e)
    }

    const { context } = await $.session.usage()
    const tokens = context.tokens

    if (tokens === undefined || context.window <= 0) {
      return next(e)
    }

    const percent = context.percent ?? Math.round((tokens / context.window) * 100)
    const weather = forecast(percent)
    const delta = lastTurnDelta(turns, before)
    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="row" columnGap={2}>
        <Text bold color={weather.color} wrap="truncate">
          {`${weather.icon} ${weather.word}`}
        </Text>
        <Text wrap="truncate">{`${percent}%`}</Text>
        <Text dimColor wrap="truncate">
          {`${formatTokens(tokens)} / ${formatTokens(context.window)}`}
        </Text>
        {turns.length > 0 ? (
          <Text color={weather.color} wrap="truncate">
            {sparkline(turns.slice(-CHART_TURNS), context.window)}
          </Text>
        ) : null}
        {delta === null ? null : (
          <Text dimColor wrap="truncate">
            {`${delta >= 0 ? '▲ +' : '▼ -'}${formatTokens(Math.abs(delta))} last turn`}
          </Text>
        )}
      </Box>
    )
  })
}
