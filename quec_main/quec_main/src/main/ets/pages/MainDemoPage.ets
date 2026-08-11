import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { QuecTitleBar } from 'quec_basic_ui';
import { LOGIN_ROUTE } from 'quec_login_api';
import { MAIN_DEMO_ROUTE } from 'quec_main_api';
import { QuecUserModel, QuecUserService } from 'quec_user_sdk';

@HMRouter({ pageUrl: MAIN_DEMO_ROUTE })
@ComponentV2
export struct mainDemoPage {
  @Local private user: QuecUserModel | undefined = QuecUserService.getUserModel()
  @Local private isLoggingOut: boolean = false

  private async logout(): Promise<void> {
    this.isLoggingOut = true
    try {
      await QuecUserService.logout()
      HMRouterMgr.replace({ pageUrl: LOGIN_ROUTE })

    } catch (error) {
      this.getUIContext().getPromptAction().showToast({
        message: (error as Error).message
      })
    } finally {
      this.isLoggingOut = false
    }
  }

  build() {
    Column() {
      QuecTitleBar({
        title: 'MAIN DEMO',
        leftIconVisible: false
      })
      Text(`UID: ${this.user?.uid ?? '--'}`)
      Text(`Nickname: ${this.user?.nikeName ?? '--'}`)
      Text(`Phone: ${this.user?.phone ?? '--'}`)
      Text(`Email: ${this.user?.email ?? '--'}`)

      Text(`RAW: ${JSON.stringify(this.user)}`)
      Button('logout')
        .enabled(!this.isLoggingOut)
        .onClick(() => this.logout())
    }
    .width('100%')
    .height('100%')
  }
}