/**
 * App 业务功能点配置信息
 */
export class QuecOemBusinessConfigModel {
  telphone: string = ''
  mall: string = ''
  userPrivacy: string = ''
  appPrivacy: string = ''
  appPrivacyDownloadUrl: string = ''
  aboutUs: string = ''

  /** 是否裁减 */
  isHomeMode: boolean = false
  /** 是否显示家庭模式开关 */
  isShowHomeSetting: boolean = false
  appTab: string = ''
  appHelper: string = ''
  familyHelper: string = ''
  isQuecApp: boolean = true
  isShowFeedback: boolean = true
  isShowDeviceManager: boolean = false
  isShowMessageCenter: boolean = false
  quecFeedbackPanel: number = -1
  appFilingNumber: string = ''
  appOfficialWebsite: string = ''
  licenseUrl: string = ''
  isSupportMap: boolean = true
  /** 深色模式：0 正常，1 暗黑，2 自动 */
  displayMode: number = 0
  /** 商城跳转链接 */
  shoppingMallJumpLink: string = ''
  isShowPhonePush: boolean = false
  isShowSmsPush: boolean = false
  merchantNo: string = ''
  merchantSecret: string = ''
  addValuesPushPanel: number = -1
  bssClientAppId: string = ''
  isUseDynamicTabIconColor: boolean = false
  /** 用户中心功能配置（JSON 字符串） */
  userCenterConfig: string = ''
  /** 用户头像配置 */
  avatarsConfig: string = ''
  /** 首页是否使用列表 */
  isHomeList: boolean = false
  /** App 分类 */
  appCategory: string | null = null
  /** 是否支持 PayPal 支付 */
  isSupportPaypal: boolean = false
  /** 是否显示门店查询 */
  isShowStoreQuery: boolean = false
  /** 是否支持布局切换（小、中、大卡片） */
  isSupportSwitchLayout: boolean = false
  /** 是否显示电子围栏 */
  isShowElectronicFence: boolean = false
  /** 是否支持 Alexa */
  isSupportAlexa: boolean = false
  /** 是否支持 Google Assistant */
  isSupportGoogleAssistant: boolean = false
  /** Alexa 配置信息（JSON 字符串） */
  alexaConfig: string = ''
  /** Google Assistant 配置信息（JSON 字符串） */
  googleAssistantConfig: string = ''
  /** 是否显示 SOS 联系人 */
  isShowSosContact: boolean = false
  /** 是否显示维护信息 */
  isShowMaintenanceInfo: boolean = false
  /** 是否显示智能服务 */
  isShowSmartService: boolean = false
  /** 是否显示售后服务 */
  isShowAfterSalesService: boolean = false
  /** 是否显示试驾 */
  isShowTestDrive: boolean = false
  /** 是否显示服务记录 */
  isShowServiceRecords: boolean = false
  /** 是否显示车辆报失 */
  isShowVehicleLossReport: boolean = false
  /** 是否为户外 App */
  isTravelSupport: boolean = false
  /** 设备定位面板 id */
  locationPanelId: number = -1
  /** 是否显示骑行勋章 */
  isShowCyclingMedal: boolean = false
  /** 是否支持天气组件 */
  isSupportWeather: boolean = false
  /** 天气缓存时间（分钟） */
  weatherCacheTime: number = 0
  /** 是否支持审核模板 */
  isSupportReviewTemplate: boolean = false
  /** 审核账号 */
  reviewTemplateAccount: string = ''
  /** 使用的审核模板 */
  usedReviewTemplate: string = ''
  /** 是否支持欧洲数据协议展示 */
  isSupportDataAct: boolean = false
  /** 是否支持游客模式 */
  isSupportGuestMode: boolean = false
  productPanelLoadMode: string = ''
  businessPanelLoadMode: string = ''
}

/**
 * 底部 Tab 配置项
 */
export class QuecOemTab {
  module: string = ''
  title: string = ''
  tabKey: string = ''
  i18nKey: string = ''
  normalMetaDataField: string = ''
  selectedMetaDataField: string = ''
  normalUrl: string = ''
  selectUrl: string = ''
  tabOrder: number = -1
  allowBizPanel: boolean = false
  bizLabel: string = ''
  bizPanelId: number = -1
  bizPanelName: string = ''
}

/**
 * 底部 Tab 配置。Android 中由 appTabBarConfig 或 business.appTab 派生，当前尚未实现派生逻辑。
 */
export class QuecOemAppTab {
  static readonly TAB1: string = 'quec_tab1_title'
  static readonly TAB2: string = 'quec_tab2_title'
  static readonly TAB3: string = 'quec_tab3_title'

  tabs: QuecOemTab[] = []

  constructor(tabs: QuecOemTab[] = []) {
    this.tabs = tabs
  }
}
