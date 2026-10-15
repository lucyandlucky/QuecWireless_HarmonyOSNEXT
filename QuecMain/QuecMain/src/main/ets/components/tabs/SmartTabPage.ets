import { QuecTitleBar } from '@quec/basic-ui';

/**
 * 智能 tab（配置里的 smart_scene）。
 *
 * 对应 Android 通过 QuecSceneRouterURI.SCENE_URI 取到的场景 Fragment。场景列表、自动化
 * 都还没复刻，当前只有骨架。
 */
@ComponentV2
export struct SmartTabPage {
  build() {
    Column() {
      QuecTitleBar({
        title: $r('app.string.quec_tab2_title_scene'),
        leftIconVisible: false
      })
      Column() {
        Text($r('app.string.quec_tab2_title_scene'))
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
