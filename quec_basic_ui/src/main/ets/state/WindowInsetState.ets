import { AppStorageV2 } from '@kit.ArkUI'

@ObservedV2
export class WindowInsetsState {
  @Trace top: number = 0
}

export function getWindowInsetsState(): WindowInsetsState {
  const state = AppStorageV2.connect(
    WindowInsetsState,
    'WindowInsetsState',
    () => new WindowInsetsState()
  )
  if (!state) {
    throw new Error('Failed to connect WindowInsetsState')
  }
  return state
}