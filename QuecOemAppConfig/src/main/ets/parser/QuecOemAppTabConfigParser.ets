import { QuecOemAppTab, QuecOemTab } from '../model/QuecOemBusinessConfigModel';
import { QuecOemRawReader as R, QuecRawObject, QuecRawValue } from './QuecOemRawReader';

/** 解析底部 Tab 配置，兼容结构化数组和 business.appTab 的 JSON 字符串。 */
export class QuecOemAppTabConfigParser {
  private static tab(raw: QuecRawObject): QuecOemTab {
    const model: QuecOemTab = new QuecOemTab()
    model.module = R.string(raw, 'module', model.module)
    model.title = R.string(raw, 'title', model.title)
    model.tabKey = R.string(raw, 'tabKey', model.tabKey)
    model.i18nKey = R.string(raw, 'i18nKey', model.i18nKey)
    model.normalMetaDataField = R.string(raw, 'normalMetaDataField', model.normalMetaDataField)
    model.selectedMetaDataField = R.string(raw, 'selectedMetaDataField', model.selectedMetaDataField)
    model.normalUrl = R.string(raw, 'normalUrl', model.normalUrl)
    model.selectUrl = R.string(raw, 'selectUrl', model.selectUrl)
    model.tabOrder = R.number(raw, 'tabOrder', model.tabOrder)
    model.allowBizPanel = R.boolean(raw, 'allowBizPanel', model.allowBizPanel)
    model.bizLabel = R.string(raw, 'bizLabel', model.bizLabel)
    model.bizPanelId = R.number(raw, 'bizPanelId', model.bizPanelId)
    model.bizPanelName = R.string(raw, 'bizPanelName', model.bizPanelName)
    return model
  }

  private static tabs(items: QuecRawObject[]): QuecOemTab[] {
    const tabs: QuecOemTab[] = []
    for (const item of items) {
      tabs.push(QuecOemAppTabConfigParser.tab(item))
    }
    return tabs
  }

  /** business.appTab 的格式为 {"tabs":[...]}，缺失或无效时返回空数组。 */
  private static tabsFromJson(json: string): QuecOemTab[] {
    if (json.trim().length === 0) {
      return []
    }
    try {
      const root: QuecRawObject | undefined = R.asObject(JSON.parse(json) as QuecRawValue)
      if (root === undefined) {
        return []
      }
      return QuecOemAppTabConfigParser.tabs(R.objectArray(root, 'tabs'))
    } catch (error) {
      // Malformed JSON must not break startup; the caller reports the empty result.
      return []
    }
  }

  /**
   * 优先使用顶层 appTabBarConfig 数组，为空时解析 business.appTab 的 JSON。
   * 保留配置中的图标值；两处均无有效配置时返回空列表，不生成默认 Tab。
   */
  public static parse(barConfig: QuecRawObject[], businessAppTabJson: string): QuecOemAppTab {
    if (barConfig.length > 0) {
      return new QuecOemAppTab(QuecOemAppTabConfigParser.tabs(barConfig))
    }
    return new QuecOemAppTab(QuecOemAppTabConfigParser.tabsFromJson(businessAppTabJson))
  }
}
