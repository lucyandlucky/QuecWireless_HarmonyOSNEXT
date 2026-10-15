import { HMRouter } from '@hadss/hmrouter';
import { getWindowInsetsState, WindowInsetsState } from '@quec/basic-ui';
import { QuecHomePageServiceManager } from '@quec/home-page-api';
import { QLog } from '@quec/log';
import { MAIN_ROUTE } from '@quec/main-api';
import { QuecGlobalConfig, QuecOemTab } from '@quec/oem-app-config';
import { QuecPersonalCenterServiceManager } from '@quec/personal-center-api';

import { MainTabBarItem } from '../components/tabs/MainTabBarItem';
import { TabContentHost } from '../components/tabs/TabContentHost';
import { MainUiState } from '../state/MainUiState';
import { MainViewModel } from '../viewmodel/MainViewModel';

const TAG: string = 'MainPage'
const TAB_BAR_CONTENT_HEIGHT: number = 56

/** 仅在 UI 层把原始 Tab 配置与页面绑定，配置模型不持有 UI 构建器。 */
class MainTabContent {
  readonly tab: QuecOemTab
  readonly page: WrappedBuilder<[]>

  constructor(tab: QuecOemTab, page: WrappedBuilder<[]>) {
    this.tab = tab
    this.page = page
  }
}

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
  @Local private tabContents: MainTabContent[] = []
  private tabPagesInitialized: boolean = false

  /** 根据 Tab 配置选择页面，返回 Builder。 */
  private getPageForTab(tab: QuecOemTab): WrappedBuilder<[]> | undefined {
    if (tab.title === QuecGlobalConfig.quecTabNames[QuecGlobalConfig.tab1]) {
      return QuecHomePageServiceManager.getInstance().getHomePageBuilder()
    } else if (tab.title === QuecGlobalConfig.quecTabNames[QuecGlobalConfig.tab2]) {
      return QuecHomePageServiceManager.getInstance().getHomePageBuilder()
    } else if (tab.title === QuecGlobalConfig.quecTabNames[QuecGlobalConfig.tab3]) {
      return QuecPersonalCenterServiceManager.getInstance().getPersonalCenterBuilder()
    } else {
      return undefined
    }
  }

  /**
   * 对应 Android initFragments：按配置顺序解析一次并保存页面。
   * Tab 栏和内容共用这份列表，缺失页面时一起跳过，避免下标错位。
   */
  private initTabPages(): void {
    if (this.tabPagesInitialized) {
      return
    }
    const contents: MainTabContent[] = []
    for (const tab of this.state.tabs) {
      const page: WrappedBuilder<[]> | undefined = this.getPageForTab(tab)
      if (page === undefined) {
        QLog.e(TAG, `no page for tabKey '${tab.tabKey}', skipped`)
        continue
      }
      contents.push(new MainTabContent(tab, page))
    }
    this.tabContents = contents
    this.tabPagesInitialized = true
  }

  aboutToAppear(): void {
    this.viewModel.init()
    this.initTabPages()
  }

  @Builder
  TabBarBuilder(item: QuecOemTab, index: number) {
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
          this.tabContents,
          (content: MainTabContent, index: number) => {
            TabContent() {
              TabContentHost({ page: content.page })
            }
            .tabBar(this.TabBarBuilder(content.tab, index))
          },
          (content: MainTabContent) => content.tab.tabKey
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
