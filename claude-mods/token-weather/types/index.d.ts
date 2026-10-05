export type Samples = number[]

declare module 'claude-code' {
  interface PluginState {
    'token-weather': { samples: Samples; baseline: number; isHidden: boolean }
  }
}
