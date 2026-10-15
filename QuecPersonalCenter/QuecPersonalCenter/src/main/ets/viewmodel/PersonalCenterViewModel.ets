import { QuecGlobalConfig, QuecUserCenterMainModel } from '@quec/oem-app-config'
import { QuecUserService } from '@quec/user-sdk'

import { PersonalCenterUiState } from '../state/PersonalCenterUiState'

export class PersonalCenterViewModel {
  readonly state: PersonalCenterUiState = new PersonalCenterUiState()
  readonly menuGroups: QuecUserCenterMainModel[] = this.resolveMenuGroups()
  private initialized: boolean = false
  private requestVersion: number = 0

  private resolveMenuGroups(): QuecUserCenterMainModel[] {
    const groups: QuecUserCenterMainModel[] = []
    const config = QuecGlobalConfig.userCenter
    if (config.function !== null) {
      groups.push(config.function)
    }
    if (config.other !== null) {
      groups.push(config.other)
    }
    return groups
  }

  public init(): void {
    if (this.initialized) {
      return
    }
    this.initialized = true
    this.state.user = QuecUserService.getUserModel()
    this.refreshUserInfo()
  }

  public async refreshUserInfo(): Promise<void> {
    if (!this.initialized || this.state.loadingUser || this.state.isLoggingOut) {
      return
    }
    const version: number = ++this.requestVersion
    this.state.loadingUser = true
    try {
      const user = await QuecUserService.getUserInfo()
      if (version === this.requestVersion) {
        this.state.user = user
      }
    } catch (_) {
      return
    } finally {
      if (version === this.requestVersion) {
        this.state.loadingUser = false
      }
    }
  }

  public dispose(): void {
    this.initialized = false
    this.requestVersion++
    this.state.loadingUser = false
  }
}
