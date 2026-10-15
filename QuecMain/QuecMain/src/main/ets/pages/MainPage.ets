import { HMRouter } from '@hadss/hmrouter';
import { getWindowInsetsState, WindowInsetsState } from '@quec/basic-ui';
import { QLog } from '@quec/log';
import { MAIN_ROUTE } from '@quec/main-api';

import { MainTabBarItem } from '../components/tabs/MainTabBarItem';
import { QuecTabRegistry } from '../components/tabs/QuecTabRegistry';
import { TabContentHost } from '../components/tabs/TabContentHost';
import { MainTabModel } from '../model/MainTabModel';
import { MainUiState } from '../state/MainUiState';
import { MainViewModel } from '../viewmodel/MainViewModel';

const TAG: string = 'MainPage'
const TAB_BAR_CONTENT_HEIGHT: number = 56

/**
 * App 主页面，对应 Android MainActivity。
 *
 * tab 切换不走路由：这是单个 HMRouter 页面，内部用 Tabs 管理，和 Android 的 Fragment
 * hide/show 行为一致（TabContent 切走后组件不销毁，状态保留）。在这里按返回键就是退出 App，
 * 不会退回登录页。
 */
@HMRouter({ pageUrl: MAIN_ROUTE })
@ComponentV2
export struct MainPage {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  private viewModel: MainViewModel = new MainViewModel()
  @Local private state: MainUiState = this.viewModel.state

  /**
   * 配置里的 tab 不一定都有对应组件，这里过滤掉没有的。
   *
   * 过滤放在 UI 层而不是 ViewModel：「这个 tabKey 能不能渲染」取决于 QuecTabRegistry，
   * 而那里面是 @Builder（UI 代码），ViewModel 不该依赖。这样 registry 是这份知识的唯一来源，
   * 不需要在别处维护一份 key 清单的副本。
   *
   * selectedIndex 也是这个列表的索引（Tabs 的 onChange 给的就是渲染列表里的下标），
   * 过滤和索引在同一层，不会错位。
   */
  @Computed
  get renderableTabs(): MainTabModel[] {
    const items: MainTabModel[] = []
    for (const item of this.state.tabs) {
      if (QuecTabRegistry.has(item.tabKey)) {
        items.push(item)
      } else {
        QLog.e(TAG, `no page for tabKey '${item.tabKey}', skipped`)
      }
    }
    return items
  }

  aboutToAppear(): void {
    this.viewModel.init()
  }

  @Builder
  TabBarBuilder(item: MainTabModel, index: number) {
    MainTabBarItem({
      item: item,
      selected: index === this.state.selectedIndex,
      contentHeight: TAB_BAR_CONTENT_HEIGHT,
      bottomInset: this.windowInsets.bottom
    })
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        index: this.state.selectedIndex
      }) {
        ForEach(
          this.renderableTabs,
          (item: MainTabModel, index: number) => {
            TabContent() {
              TabContentHost({ tabKey: item.tabKey })
            }
            .tabBar(this.TabBarBuilder(item, index))
          },
          (item: MainTabModel) => item.tabKey
        )
      }
      // Android 用 RecyclerView 做 tab 栏、FrameLayout 装内容，没有横滑换页，这里保持一致。
      .scrollable(false)
      .animationDuration(0)
      .barHeight(TAB_BAR_CONTENT_HEIGHT + this.windowInsets.bottom)
      .barBackgroundColor($r('app.color.B2'))
      .onChange((index: number) => {
        this.viewModel.selectTab(index)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B1'))
  }
}
