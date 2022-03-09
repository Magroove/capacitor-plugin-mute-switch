import { WebPlugin } from '@capacitor/core';

import type { MuteSwitchPlugin } from './definitions';

export class MuteSwitchWeb extends WebPlugin implements MuteSwitchPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
