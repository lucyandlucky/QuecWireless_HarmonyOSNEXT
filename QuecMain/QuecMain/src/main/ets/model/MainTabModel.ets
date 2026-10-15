/**
 * 一个 tab 渲染所需的数据，由 MainViewModel 从配置解析。
 *
 * 只放数据，不持有 WrappedBuilder —— 页面组件由 UI 层拿 tabKey 去 QuecTabRegistry 查，
 * 这样数据层不依赖 UI 构建器。
 */
export class MainTabModel {
  tabKey: string = ''
  label: ResourceStr = ''
  normalIcon: Resource | undefined = undefined
  selectedIcon: Resource | undefined = undefined

  constructor(
    tabKey: string,
    label: ResourceStr,
    normalIcon: Resource | undefined,
    selectedIcon: Resource | undefined
  ) {
    this.tabKey = tabKey
    this.label = label
    this.normalIcon = normalIcon
    this.selectedIcon = selectedIcon
  }
}
