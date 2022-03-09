import { registerPlugin } from '@capacitor/core';

import type { MuteSwitchPlugin } from './definitions';

const MuteSwitch = registerPlugin<MuteSwitchPlugin>('MuteSwitch', {
  web: () => import('./web').then(m => new m.MuteSwitchWeb()),
});

export * from './definitions';
export { MuteSwitch };
