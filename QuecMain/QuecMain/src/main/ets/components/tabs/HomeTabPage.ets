import { QuecTitleBar } from '@quec/basic-ui';

/**
 * 首页 tab（配置里的 home_page）。
 *
 * 对应 Android 的 QuecHomePageServiceManager.getHomePageFragment。设备列表、家庭模式、
 * 卡片布局都还没复刻，当前只有骨架。
 */
@ComponentV2
export struct HomeTabPage {
  build() {
    Column() {
      QuecTitleBar({
        title: $r('app.string.quec_tab1_title'),
        leftIconVisible: false
      })
      Column() {
        Text($r('app.string.quec_tab1_title'))
          .fontColor($r('app.color.W1'))
          .fontSize('20fp')
          .fontWeight(FontWeight.Medium)
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
