import { common } from '@kit.AbilityKit'
import { getWindowInsetsState, QuecTitleBar, WindowInsetsState } from 'quec_basic_ui'
import { QuecColorUtils } from 'quec_foundation'

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@ComponentV2
export struct LoginPage {
  @Consumer('AppNavigation')
  private navigation: NavPathStack = new NavPathStack()
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()

  private moveAppToBackground(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    context.moveAbilityToBackground().catch()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
        }
        .width('100%')
        .height(this.windowInsets.top + 180)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [QuecColorUtils.getColorWithAlpha(0.12, $r('app.color.M1')), 0],
            [QuecColorUtils.getColorWithAlpha(0.02, $r('app.color.B1')), 1]
          ]
        })

        Column() {
          QuecTitleBar({
            transparent: true,
            rightText: {
              text: $r('app.string.quec_login_register'),
              color: $r('app.color.W2'),
              onClick: () => {
              },
            }
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
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
