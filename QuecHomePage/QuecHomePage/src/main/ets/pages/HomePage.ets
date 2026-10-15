import { QuecTitleBar } from '@quec/basic-ui'

/** 首页 Tab 内容，路由栈由主容器管理。 */
@ComponentV2
export struct HomePage {
  build() {
    Column() {
      QuecTitleBar({
        title: $r('app.string.quec_home_page_title'),
        leftIconVisible: false
      })
      Column({ space: 16 }) {
        Image($r('app.media.quec_home_page_placeholder'))
          .width(180)
          .height(144)
          .objectFit(ImageFit.Contain)
        Text($r('app.string.quec_home_page_placeholder'))
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
