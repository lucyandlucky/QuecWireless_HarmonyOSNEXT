@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@ComponentV2
export struct LoginPage {
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
  }
}
