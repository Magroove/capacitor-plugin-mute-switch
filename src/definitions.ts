export interface MuteSwitchPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
