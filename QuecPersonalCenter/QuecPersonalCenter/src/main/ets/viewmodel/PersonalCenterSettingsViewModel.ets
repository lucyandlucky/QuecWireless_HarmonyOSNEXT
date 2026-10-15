import { QuecUserService } from '@quec/user-sdk'

import { PersonalCenterUiState } from '../state/PersonalCenterUiState'

export class PersonalCenterSettingsViewModel {
  readonly state: PersonalCenterUiState

  constructor(state: PersonalCenterUiState) {
    this.state = state
  }

  public async logout(): Promise<boolean> {
    if (this.state.isLoggingOut || this.state.loadingUser) {
      return false
    }
    this.state.isLoggingOut = true
    try {
      await QuecUserService.logout()
      return true
    } finally {
      this.state.isLoggingOut = false
    }
  }
}
