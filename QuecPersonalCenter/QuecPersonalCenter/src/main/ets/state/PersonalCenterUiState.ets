import { QuecUserModel } from '@quec/user-sdk'

@ObservedV2
export class PersonalCenterUiState {
  @Trace user: QuecUserModel | undefined = undefined
  @Trace loadingUser: boolean = false
  @Trace isLoggingOut: boolean = false
}
