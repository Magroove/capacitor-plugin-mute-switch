import { WebPlugin } from '@capacitor/core';

import type { MuteSwitchPlugin, MuteSwitchResponse } from './definitions';

export class MuteSwitchWeb extends WebPlugin implements MuteSwitchPlugin {
  initialize(): Promise<MuteSwitchResponse> {
    return Promise.resolve({ status: 'error' });
  }
}