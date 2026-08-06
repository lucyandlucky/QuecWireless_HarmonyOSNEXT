import { common } from '@kit.AbilityKit'
import { getWindowInsetsState, QuecTitleBar, WindowInsetsState } from 'quec_basic_ui'
import { QuecColorUtils } from 'quec_foundation'
import { QuecLoginButton } from '../components/QuecLoginButton'
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
                placeholder: $r('app.string.quec_login_account')
              })
              QuecUnderlineTextInput({
                placeholder: $r('app.string.quec_login_psd')
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

            Row() {
              Stack({ alignContent: Alignment.Center }) {
                Image(this.hasAgreedPolicy
                  ? $r('app.media.quec_login_check_box_on')
                  : $r('app.media.quec_login_check_box_off'))
                  .width(20)
                  .height(20)
                  .objectFit(ImageFit.Contain)
              }
              .margin({ right: 4 })
              .onClick(() => {
                this.hasAgreedPolicy = !this.hasAgreedPolicy
              })

              Text() {
                Span($r('app.string.quec_login_agree'))
                Span($r('app.string.quec_login_user_privacy'))
                  .fontColor($r('app.color.M1'))
                Span($r('app.string.quec_login_add'))
                Span($r('app.string.quec_login_privacy'))
                  .fontColor($r('app.color.M1'))
              }
              .layoutWeight(1)
              .fontSize(14)
              .lineHeight(20)
              .fontColor($r('app.color.W2'))
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
            .margin({ top: 16 })

            QuecLoginButton()

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
