import { QLog } from '@quec/log';

const TAG: string = 'QuecTabResources'
const PNG_SUFFIX: string = '.png'

/**
 * 配置里 tab 图标名到本地资源的映射。
 *
 * 新增图标时：把 png 放进 src/main/resources/base/media，再往这张表里加一行。
 */
const TAB_ICONS: Map<string, Resource> = new Map<string, Resource>()
TAB_ICONS.set('quec_tab1_title_normal', $r('app.media.quec_tab1_title_normal'))
TAB_ICONS.set('quec_tab1_title_select', $r('app.media.quec_tab1_title_select'))
TAB_ICONS.set('quec_tab2_title_scene_normal', $r('app.media.quec_tab2_title_scene_normal'))
TAB_ICONS.set('quec_tab2_title_scene_select', $r('app.media.quec_tab2_title_scene_select'))
TAB_ICONS.set('quec_tab3_title_normal', $r('app.media.quec_tab3_title_normal'))
TAB_ICONS.set('quec_tab3_title_select', $r('app.media.quec_tab3_title_select'))

/**
 * 配置里 i18nKey（缺失时退化为 title）到本地字符串资源的映射。
 *
 * 新增 tab 文案时：往三个 locale 的 string.json 里加 key，再往这张表里加一行。
 */
const TAB_LABELS: Map<string, Resource> = new Map<string, Resource>()
TAB_LABELS.set('quec_tab1_title', $r('app.string.quec_tab1_title'))
TAB_LABELS.set('quec_tab2_title_scene', $r('app.string.quec_tab2_title_scene'))
TAB_LABELS.set('quec_tab3_title', $r('app.string.quec_tab3_title'))

/**
 * 把配置里的名字解析成本地资源。
 *
 * 对应 Android 的 MainTabAdapter.setIcon（`QuecResourceUtil.getMipmapIdByName`）和
 * convert 里的 `getStringIdByName`，两者都是按名字反射查资源表。鸿蒙的 `$r()` 是编译期常量，
 * 没有等价物，所以显式列成表。
 *
 * 这样反而更好：可选资源本来就是打包进 App 的有限集合，配置只是在集合里选一个；写成表之后
 * 缺资源在这个文件里一眼能看出来，而 Android 那套反射查不到是静默不显示。代价是配置平台
 * 新增 tab 时要改代码 —— 但新增 tab 本来就要补图和文案，已经要改代码了。
 */
export class QuecTabResources {
  /**
   * 配置里的图标值可能是 'quec_tab1_title_normal.png'，也可能是一个完整的 http 地址
   * （business 段里的 quecTab1Normal 就是 OSS 地址）。两种都归一化成资源名，
   * 与 Android 的处理一致：取 URL 的文件名、去掉 .png。
   */
  private static normalizeIconName(value: string): string {
    let name: string = value.trim()
    if (name.startsWith('http://') || name.startsWith('https://')) {
      const query: number = name.indexOf('?')
      if (query >= 0) {
        name = name.substring(0, query)
      }
      name = name.substring(name.lastIndexOf('/') + 1)
    }
    if (name.toLowerCase().endsWith(PNG_SUFFIX)) {
      name = name.substring(0, name.length - PNG_SUFFIX.length)
    }
    return name
  }

  /**
   * 查不到时返回 undefined，调用方不渲染图标。缺一张图不该让整个 tab 栏不可用。
   */
  public static icon(value: string): Resource | undefined {
    if (value.length === 0) {
      return undefined
    }
    const name: string = QuecTabResources.normalizeIconName(value)
    const icon: Resource | undefined = TAB_ICONS.get(name)
    if (icon === undefined) {
      QLog.w(TAG, `no local icon for '${name}', raw value: '${value}'`)
    }
    return icon
  }

  /**
   * i18nKey 优先，为空时退化用 title，与 Android MainTabAdapter.convert 的顺序一致。
   */
  public static label(i18nKey: string, title: string): Resource | undefined {
    const key: string = i18nKey.length > 0 ? i18nKey : title
    if (key.length === 0) {
      QLog.e(TAG, 'tab has neither i18nKey nor title')
      return undefined
    }
    const label: Resource | undefined = TAB_LABELS.get(key)
    if (label === undefined) {
      QLog.w(TAG, `no local label for '${key}'`)
    }
    return label
  }
}
