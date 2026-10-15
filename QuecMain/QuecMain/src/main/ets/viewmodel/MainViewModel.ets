import { QLog } from '@quec/log';
import { QuecGlobalConfig, QuecOemTab } from '@quec/oem-app-config';

import { MainTabModel } from '../model/MainTabModel';
import { MainUiState } from '../state/MainUiState';
import { QuecTabResources } from '../utils/QuecTabResources';

const TAG: string = 'MainViewModel'

/**
 * 对应 Android MainTabUtil 里和 tab 列表相关的那部分（getConfigTab）。
 *
 * tab 完全由 app_config.yml 驱动：配置里有几个就产出几个、顺序就是配置的数组顺序，
 * 这里不做任何代码侧的白名单过滤。「这个 tabKey 有没有对应组件」是 UI 层的知识，
 * 由 MainPage 查 QuecTabRegistry 决定。
 *
 * 没有 repository：数据来自本地配置 QuecGlobalConfig，没有网络请求，加一层只是纯转发。
 */
export class MainViewModel {
  readonly state: MainUiState = new MainUiState()
  private initialized: boolean = false

  /**
   * 不按 tabOrder 排序：Android 也是直接用数组顺序，配置里 tabOrder 与数组顺序本来一致，
   * 真要排序得先确认配置平台是否允许两者不一致。
   */
  private static resolveTabs(): MainTabModel[] {
    const tabs: QuecOemTab[] = QuecGlobalConfig.appTab.tabs
    const items: MainTabModel[] = []
    for (const tab of tabs) {
      items.push(new MainTabModel(
        tab.tabKey,
        QuecTabResources.label(tab.i18nKey, tab.title) ?? '',
        QuecTabResources.icon(tab.normalUrl),
        QuecTabResources.icon(tab.selectUrl)
      ))
    }
    QLog.i(TAG, `resolved ${items.length} tabs from config`)
    return items
  }

  public init(): void {
    if (this.initialized) {
      return
    }
    this.initialized = true
    this.state.tabs = MainViewModel.resolveTabs()
  }

  public selectTab(index: number): void {
    this.state.selectedIndex = index
  }
}
