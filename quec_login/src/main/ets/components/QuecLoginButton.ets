@ComponentV2
export struct QuecLoginButton {
  build() {
    Button($r('app.string.quec_login'))
      .onClick((event: ClickEvent) => {

      })
      .width('100%')
      .padding({ top: 16, bottom: 16 })
      .borderRadius(43)
      .fontSize(16)
      .fontColor(Color.White)
      .fontWeight(FontWeight.Medium)
      .backgroundColor($r('app.color.M1'))
      .margin({ top: 24 })
  }
}