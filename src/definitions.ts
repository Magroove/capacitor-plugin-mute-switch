export interface MuteSwitchPlugin {
  initialize(): Promise<MuteSwitchResponse>;
}

export type MuteSwitchResponse = { status: MuteSwitchStatus };

export type MuteSwitchStatus = 'success' | 'error';