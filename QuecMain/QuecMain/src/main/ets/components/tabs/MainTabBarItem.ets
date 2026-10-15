import { QuecOemTab } from '@quec/oem-app-config';

import { QuecTabResources } from '../../utils/QuecTabResources';

const TAB_ICON_SIZE: number = 24

@ComponentV2
export struct MainTabBarItem {
  @Param item: QuecOemTab = new QuecOemTab()
  @Param selected: boolean = false
  @Param contentHeight: number = 56
  @Param bottomInset: number = 0

  @Computed
  get icon(): Resource | undefined {
    return QuecTabResources.icon(this.selected ? this.item.selectUrl : this.item.normalUrl)
  }

  @Computed
  get label(): ResourceStr {
    return QuecTabResources.label(this.item.i18nKey, this.item.title) ?? ''
  }

  @Computed
  get labelColor(): ResourceColor {
    return this.selected ? $r('app.color.M0') : $r('app.color.W2')
  }

  build() {
    Column({ space: 2 }) {
      if (this.icon !== undefined) {
        Image(this.icon)
          .width(TAB_ICON_SIZE)
          .height(TAB_ICON_SIZE)
      }
      Text(this.label)
        .fontColor(this.labelColor)
        .fontSize('10fp')
    }
    .width('100%')
    // 高度含底部避让区，让 tab 栏背景铺满到屏幕底边，内容靠 padding 顶上去。
    .height(this.contentHeight + this.bottomInset)
    .padding({ bottom: this.bottomInset })
    .justifyContent(FlexAlign.Center)
  }
}
