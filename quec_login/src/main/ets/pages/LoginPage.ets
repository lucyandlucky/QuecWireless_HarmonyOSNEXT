import { common } from '@kit.AbilityKit'

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@ComponentV2
export struct LoginPage {
  @Consumer('AppNavigation')
  private navigation: NavPathStack = new NavPathStack()

  private moveAppToBackground(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    context.moveAbilityToBackground().catch()
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.quec_login_title'))
          .fontSize($r('app.float.T8_F'))
          .fontColor($r('app.color.W1'))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.B2'))
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (this.navigation.size() > 1) {
        return false
      }
      this.moveAppToBackground()
      return true
    })
  }
}
