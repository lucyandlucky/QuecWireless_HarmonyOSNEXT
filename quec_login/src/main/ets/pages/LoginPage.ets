import { common } from '@kit.AbilityKit'
import { getWindowInsetsState, QuecTitleBar, WindowInsetsState } from 'quec_basic_ui'
import { QuecColorUtils } from 'quec_foundation'
import { QuecLoginButton } from '../components/QuecLoginButton'
import { QuecLoginPolicy } from '../components/QuecLoginPolicy'
import { QuecUnderlineTextInput } from '../components/QuecUnderlineTextInput'

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@ComponentV2
export struct LoginPage {
  @Consumer('AppNavigation')
  private navigation: NavPathStack = new NavPathStack()
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  @Local private hasAgreedPolicy: boolean = false
  @Local private account: string = ''
  @Local private password: string = ''

  @Computed
  get loginVerify(): boolean {
    return this.account.length >= 1 && this.password.length >= 6
  }

  private moveAppToBackground(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    context.moveAbilityToBackground().catch()
  }

  private onLogin(): void {


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
            leftIconVisible: false,
            rightText: {
              text: $r('app.string.quec_login_register'),
              color: $r('app.color.W2'),
              onClick: () => {
              },
            }
          })

          Column() {
            Text($r('app.string.quec_password_login'))
              .fontColor($r('app.color.W1'))
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
            Column({ space: 45 }) {
              QuecUnderlineTextInput({
                value: this.account,
                placeholder: $r('app.string.quec_login_account'),
                onValueChange: (val) => {
                  this.account = val
                }
              })
              QuecUnderlineTextInput({
                inputType: InputType.Password,
                value: this.password,
                placeholder: $r('app.string.quec_login_psd'),
                onValueChange: (val) => {
                  this.password = val
                }
              })
            }.margin({ top: 52 })

            Text($r('app.string.quec_login_forget'))
              .width('100%')
              .textAlign(TextAlign.RIGHT)
              .fontSize(14)
              .fontColor($r('app.color.W2'))
              .margin({ top: 5 })
              .onClick(() => {
                console.log('ready to navigate forget page')
              })

            QuecLoginPolicy({
              checked: this.hasAgreedPolicy,
              onChecked: (checked) => {
                this.hasAgreedPolicy = checked
              }
            })
              .margin({ top: 16 })

            QuecLoginButton({
              text: $r('app.string.quec_login'),
              verify: this.loginVerify,
              onLogin: this.onLogin
            })

            Text($r('app.string.quec_login_code'))
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(14)
              .fontColor($r('app.color.W2'))
              .margin({ top: 24 })
          }
          .padding({ top: 12, left: 28, right: 28 })
          .alignItems(HorizontalAlign.Start)

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
