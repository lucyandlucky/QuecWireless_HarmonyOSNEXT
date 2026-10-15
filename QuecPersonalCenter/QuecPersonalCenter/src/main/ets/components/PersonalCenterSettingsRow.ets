@ComponentV2
export struct PersonalCenterSettingsRow {
  @Param title: ResourceStr = ''
  @Param value: string = ''
  @Param badge: string = ''
  @Param showArrow: boolean = true
  @Param darkModeArrow: boolean = false
  @Event onItemClick: () => void = () => {
  }

  build() {
    Row() {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .lineHeight(22)
        .fontColor($r('app.color.W1'))
        .layoutWeight(1)
      if (this.badge.length > 0) {
        Text(this.badge)
          .fontSize(12)
          .lineHeight(12)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .constraintSize({ minWidth: 16 })
          .borderRadius(25)
          .backgroundColor($r('app.color.quec_personal_center_error'))
      }
      if (this.value.length > 0) {
        Text(this.value)
          .fontSize(14)
          .lineHeight(20)
          .fontColor($r('app.color.W3'))
      }
      if (this.showArrow) {
        Image(this.darkModeArrow
          ? $r('app.media.quec_personal_center_dark_mode_arrow')
          : $r('app.media.quec_personal_center_setting_arrow'))
          .width(20)
          .height(20)
      }
    }
    .width('100%')
    .height(54)
    .padding({ left: 20, right: this.darkModeArrow ? 12 : 20 })
    .onClick(() => this.onItemClick())
    .accessibilityGroup(true)
  }
}
