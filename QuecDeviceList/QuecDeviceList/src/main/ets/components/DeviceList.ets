@ComponentV2
export struct DeviceList {
  build() {
    Column() {
      Text('demo')
        .fontColor($r('app.color.W2'))
        .fontSize('14fp')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.B1'))
  }
}
