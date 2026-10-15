import { QuecOemAppTab, QuecOemBusinessConfigModel, QuecOemTab } from '../model/QuecOemBusinessConfigModel';
import { QuecOemAppName, QuecOemBasicConfigModel } from '../model/QuecOemBasicConfigModel';
import { QuecOemNetwork, QuecOemNetworkConfigModel } from '../model/QuecOemNetworkConfigModel';
import { QuecOemRawReader as R, QuecRawObject, QuecRawValue } from './QuecOemRawReader';

/**
 * Converts raw YAML objects into config models. Every field not present in the raw object keeps the
 * model's Android default value; raw fields unknown to the Android models are ignored.
 */
export class QuecOemModelParser {
  private static appName(raw: QuecRawObject | undefined): QuecOemAppName {
    const model: QuecOemAppName = new QuecOemAppName()
    model.cn = R.string(raw, 'cn', model.cn)
    model.en = R.string(raw, 'en', model.en)
    return model
  }

  private static networkConfig(raw: QuecRawObject | undefined): QuecOemNetworkConfigModel {
    const model: QuecOemNetworkConfigModel = new QuecOemNetworkConfigModel()
    model.environment = R.string(raw, 'environment', model.environment)
    model.baseUrl = R.string(raw, 'baseUrl', model.baseUrl)
    model.webSocketUrl = R.string(raw, 'webSocketUrl', model.webSocketUrl)
    model.webSocketV2Url = R.string(raw, 'webSocketV2Url', model.webSocketV2Url)
    model.saasUrl = R.string(raw, 'saasUrl', model.saasUrl)
    model.userDomain = R.string(raw, 'userDomain', model.userDomain)
    model.userDomainSecret = R.string(raw, 'userDomainSecret', model.userDomainSecret)
    model.ssid = R.string(raw, 'ssid', model.ssid)
    model.resetPswStid = R.string(raw, 'resetPswStid', model.resetPswStid)
    model.loginStid = R.string(raw, 'loginStid', model.loginStid)
    model.registerStid = R.string(raw, 'registerStid', model.registerStid)
    model.cancelStid = R.string(raw, 'cancelStid', model.cancelStid)
    model.eaid = R.string(raw, 'eaid', model.eaid)
    model.resetPswEtid = R.string(raw, 'resetPswEtid', model.resetPswEtid)
    model.registerEtid = R.string(raw, 'registerEtid', model.registerEtid)
    model.cancelEtid = R.string(raw, 'cancelEtid', model.cancelEtid)
    model.bootstrapUrl = R.string(raw, 'bootstrapUrl', model.bootstrapUrl)
    model.bootstrapPath = R.string(raw, 'bootstrapPath', model.bootstrapPath)
    model.bootstrapToken = R.string(raw, 'bootstrapToken', model.bootstrapToken)
    return model
  }

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
      tabs.push(QuecOemModelParser.tab(item))
    }
    return tabs
  }

  /**
   * Reads the tabs embedded in business.appTab, which the config platform stores as the JSON
   * string {"tabs":[...]}. Returns an empty list when the text is absent or malformed.
   */
  private static tabsFromJson(json: string): QuecOemTab[] {
    if (json.trim().length === 0) {
      return []
    }
    try {
      const root: QuecRawObject | undefined = R.asObject(JSON.parse(json) as QuecRawValue)
      if (root === undefined) {
        return []
      }
      return QuecOemModelParser.tabs(R.objectArray(root, 'tabs'))
    } catch (error) {
      // Malformed JSON must not break startup; the caller reports the empty result.
      return []
    }
  }

  public static basic(raw: QuecRawObject | undefined): QuecOemBasicConfigModel {
    const model: QuecOemBasicConfigModel = new QuecOemBasicConfigModel()
    model.bundleId = R.string(raw, 'bundleId', model.bundleId)
    model.appVersion = R.string(raw, 'appVersion', model.appVersion)
    model.appVersionCode = R.string(raw, 'appVersionCode', model.appVersionCode)
    const appName: QuecRawObject | undefined = R.object(raw, 'appName')
    if (appName !== undefined) {
      model.appName = QuecOemModelParser.appName(appName)
    }
    model.area = R.string(raw, 'area', model.area)
    model.appTypeId = R.number(raw, 'appTypeId', model.appTypeId)
    return model
  }

  public static network(raw: QuecRawObject | undefined): QuecOemNetwork {
    const model: QuecOemNetwork = new QuecOemNetwork()
    model.china = QuecOemModelParser.networkConfig(R.object(raw, 'china'))
    model.europe = QuecOemModelParser.networkConfig(R.object(raw, 'europe'))
    model.northAmerica = QuecOemModelParser.networkConfig(R.object(raw, 'northAmerica'))
    return model
  }

  /** 当前解析底部 Tab 和个人中心基础菜单所需的业务字段。 */
  public static business(raw: QuecRawObject | undefined): QuecOemBusinessConfigModel {
    const model: QuecOemBusinessConfigModel = new QuecOemBusinessConfigModel()
    model.appTab = R.string(raw, 'appTab', model.appTab)
    model.userCenterConfig = R.string(raw, 'userCenterConfig', model.userCenterConfig)
    model.isHomeList = R.boolean(raw, 'isHomeList', model.isHomeList)
    model.isShowDeviceManager = R.boolean(raw, 'isShowDeviceManager', model.isShowDeviceManager)
    model.isShowMessageCenter = R.boolean(raw, 'isShowMessageCenter', model.isShowMessageCenter)
    model.isShowFeedback = R.boolean(raw, 'isShowFeedback', model.isShowFeedback)
    model.quecFeedbackPanel = R.number(raw, 'quecFeedbackPanel', model.quecFeedbackPanel)
    return model
  }

  /**
   * 对应 Android QuecOemConfigManager.getAppTab。配置文件里这两处内容重复，顶层
   * appTabBarConfig 已是结构化数组，优先使用；只有它缺失时才解析 business.appTab 的 JSON。
   *
   * 与 Android 的区别：不实现第三层硬编码默认 tab。配置随包发布，读不到就应当暴露出来，
   * 而不是用一组写死的值掩盖（与 QuecGlobalConfig 不保存配置副本的取向一致）。
   * 另外不照搬 Android 在 JSON 分支里覆写 normalUrl/selectUrl 的那段：它用的是另一套图标
   * 命名，且 TAB2/TAB3 的选中图被写成了未选中图。
   */
  public static appTab(barConfig: QuecRawObject[], businessAppTabJson: string): QuecOemAppTab {
    if (barConfig.length > 0) {
      return new QuecOemAppTab(QuecOemModelParser.tabs(barConfig))
    }
    return new QuecOemAppTab(QuecOemModelParser.tabsFromJson(businessAppTabJson))
  }
}
