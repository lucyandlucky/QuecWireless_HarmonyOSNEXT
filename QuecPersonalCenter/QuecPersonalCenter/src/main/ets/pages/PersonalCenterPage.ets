import { HMRouterMgr } from '@hadss/hmrouter';
import { QuecTitleBar } from '@quec/basic-ui';
import { LOGIN_ROUTE } from '@quec/login-api';
import { QuecUserModel, QuecUserService } from '@quec/user-sdk';

@ComponentV2
export struct PersonalCenterPage {
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

  @Builder
  FieldBuilder(label: string, value: string) {
    Row() {
      Text(label)
        .fontColor($r('app.color.W2'))
        .fontSize('14fp')
      Blank()
      Text(value)
        .fontColor($r('app.color.W1'))
        .fontSize('14fp')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  build() {
    Column() {
      QuecTitleBar({
        title: '个人中心',
        leftIconVisible: false
      })
      Column() {
        this.FieldBuilder('UID', this.user?.uid ?? '--')
        this.FieldBuilder('Nickname', this.user?.nikeName ?? '--')
        this.FieldBuilder('Phone', this.user?.phone ?? '--')
        this.FieldBuilder('Email', this.user?.email ?? '--')
        Blank()
        Button($r('app.string.quec_user_signout'))
          .width('100%')
          .enabled(!this.isLoggingOut)
          .onClick(() => this.logout())
      }
      .layoutWeight(1)
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 16
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B1'))
  }
}
