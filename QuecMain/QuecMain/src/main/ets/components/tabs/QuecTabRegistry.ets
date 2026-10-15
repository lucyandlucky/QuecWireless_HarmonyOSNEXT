import { QLog } from '@quec/log';

import { HomeTabPage } from './HomeTabPage';
import { ProfileTabPage } from './ProfileTabPage';
import { SmartTabPage } from './SmartTabPage';

const TAG: string = 'QuecTabRegistry'

@Builder
function homeBuilder() {
  HomeTabPage()
}

@Builder
function smartBuilder() {
  SmartTabPage()
}

@Builder
function profileBuilder() {
  ProfileTabPage()
}

/**
 * app_config.yml 里的 tabKey 到页面组件的映射，是这份映射的唯一来源。
 *
 * 显示哪些 tab、什么顺序完全由配置决定（见 MainViewModel）；这里只回答「这个 tabKey 对应
 * 哪个组件」—— 配置能选择和排列，但不能凭空产生页面组件，组件是编译进包里的。Android 同理，
 * MainTabUtil.getFragmentForTab 就是一串硬编码分支。
 *
 * key 直接写配置里的字面量，不走常量类：每个字符串只在这里出现一次，没有重复可消除，
 * 加一层常量只是把字符串搬到别处再 import 回来。
 *
 * 新增 tab：配置里加一项，这里登记对应组件，再往 QuecTabResources 的两张表里补图和文案。
 * 配置里出现这里没登记的 tabKey 会被 MainPage 跳过并打日志，对应 Android
 * MainTabUtil.initFragments 里 fragment 为 null 就 log 并跳过的行为。
 *
 * 不移植 Android 的 bizPanelId != -1 走 RN 面板的分支，鸿蒙没有 RN。
 *
 * 真实页面分到各自模块后，这张 Map 换成 HMRouter 的服务路由取 builder：提供方
 * `@HMService({ serviceName })` 返回 WrappedBuilder，这里用
 * `HMRouterMgr.getService<WrappedBuilder<[]>>(name)`。服务缺失（模块被 OEM 裁剪）时返回
 * undefined，与现在查不到的处理一致。换的时候只改这个文件。
 */
const TAB_PAGES: Map<string, WrappedBuilder<[]>> = new Map<string, WrappedBuilder<[]>>()
TAB_PAGES.set('home_page', wrapBuilder(homeBuilder))
TAB_PAGES.set('smart_scene', wrapBuilder(smartBuilder))
TAB_PAGES.set('about_me', wrapBuilder(profileBuilder))

export class QuecTabRegistry {
  /** 纯查询，不打日志，供 MainPage 过滤配置用 */
  public static has(tabKey: string): boolean {
    return TAB_PAGES.has(tabKey)
  }

  public static page(tabKey: string): WrappedBuilder<[]> | undefined {
    const builder: WrappedBuilder<[]> | undefined = TAB_PAGES.get(tabKey)
    if (builder === undefined) {
      QLog.e(TAG, `no builder for tabKey '${tabKey}'`)
    }
    return builder
  }
}
