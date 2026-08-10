@ComponentV2
export struct QuecLoginButton {
  @Param text: ResourceStr = ''
  @Param verify: boolean = false
  @Event onLogin: () => void = () => {
  }

  build() {
    Button(this.text)
      .onClick(() => {
        console.log('this.verify', this.verify)
        if (!this.verify) {
          return
        }
        this.onLogin()
      })
      .enabled(this.verify)
      .width('100%')
      .padding({ top: 16, bottom: 16 })
      .borderRadius(43)
      .fontSize(16)
      .fontColor(Color.White)
      .fontWeight(FontWeight.Medium)
      .backgroundColor($r('app.color.M1'))
      .opacity(this.verify ? 1 : 0.45)
      .margin({ top: 24 })
      .animation({
        duration: 220,
        curve: Curve.EaseInOut
      })

  }
}