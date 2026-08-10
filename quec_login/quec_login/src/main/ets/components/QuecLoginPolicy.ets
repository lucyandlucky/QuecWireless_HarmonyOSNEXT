@ComponentV2
export struct QuecLoginPolicy {
  @Param checked: boolean = false
  @Param checkedIconVisible: boolean = true
  @Event onChecked: (checked: boolean) => void = () => {
  }

  build() {
    Row() {
      if (this.checkedIconVisible) {
        Stack({ alignContent: Alignment.Center }) {
          Image(this.checked
            ? $r('app.media.quec_login_check_box_on')
            : $r('app.media.quec_login_check_box_off'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
        }
        .margin({ right: 4 })
        .onClick(() => {
          this.onChecked(!this.checked)
        })
      }

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
  }
}