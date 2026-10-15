import { QLog } from '@quec/log';
import { QuecGlobalConfig } from '@quec/oem-app-config';

import { MainUiState } from '../state/MainUiState';

const TAG: string = 'MainViewModel'

/**
 * 对应 Android MainTabUtil 里和 tab 列表相关的那部分（getConfigTab）。
 *
 * 直接使用配置的 QuecOemTab，保留 bizPanelId 等完整字段。顺序就是配置的数组顺序，
 * 这里不做任何代码侧的白名单过滤。「这个 tabKey 有没有对应组件」是 UI 层的知识，
 * 由 MainPage.getPageForTab 决定。
 *
 * 没有 repository：数据来自本地配置 QuecGlobalConfig，没有网络请求，加一层只是纯转发。
 */
export class MainViewModel {
  readonly state: MainUiState = new MainUiState()
  private initialized: boolean = false

  public init(): void {
    if (this.initialized) {
      return
    }
    this.initialized = true
    // 与 Android 一样直接使用配置数组顺序，不按 tabOrder 重新排序。
    this.state.tabs = QuecGlobalConfig.appTab.tabs
    QLog.i(TAG, `loaded ${this.state.tabs.length} tabs from config`)
  }

  public selectTab(index: number): void {
    this.state.selectedIndex = index
  }
}
