import { MainTabModel } from '../../model/MainTabModel';

const TAB_ICON_SIZE: number = 24

/**
 * 底部 tab 栏的一项，对应 Android MainTabAdapter.convert。
 *
 * 还没做的两件事：
 * - 动态图标着色。配置 isUseDynamicTabIconColor 是 true，Android 用 ReplaceIconColorUtil
 *   把选中图标的像素替换成 M0、选中文字也用 M0；鸿蒙 Image.fillColor() 只对 SVG 生效，
 *   PNG 要操作 PixelMap，所以当前按 false 分支走、选中文字用 W1，与 Android 有视觉差异。
 * - 消息红点（Android 的 img_badge），依赖还没移植的 MessageCenter 模块。
 */
@ComponentV2
export struct MainTabBarItem {
  @Param item: MainTabModel = new MainTabModel('', '', undefined, undefined)
  @Param selected: boolean = false
  @Param contentHeight: number = 56
  @Param bottomInset: number = 0

  @Computed
  get icon(): Resource | undefined {
    return this.selected ? this.item.selectedIcon : this.item.normalIcon
  }

  @Computed
  get labelColor(): ResourceColor {
    return this.selected ? $r('app.color.W1') : $r('app.color.W2')
  }

  build() {
    Column({ space: 2 }) {
      if (this.icon !== undefined) {
        Image(this.icon)
          .width(TAB_ICON_SIZE)
          .height(TAB_ICON_SIZE)
      }
      Text(this.item.label)
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
