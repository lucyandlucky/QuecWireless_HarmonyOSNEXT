
/** 首页 Tab 内容，路由栈由主容器管理。 */
@ComponentV2
export struct HomePage {
  build() {
    Column() {
      Column() {
        Text($r('app.string.quec_device_list'))
          .fontColor($r('app.color.W2'))
          .fontSize('14fp')
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B1'))
  }
}
