export interface QuecAppBasicConfig {
  bundleId: string
  appName: QuecAppName
  appVersion: string
  appVersionCode: number
  area: string
  appTypeId: number
}

export interface QuecAppName {
  cn: string
  en: string
}

export interface QuecAppNetworkConfig {
  environment: string
  baseUrl: string
  webSocketUrl: string
  webSocketV2Url: string
  userDomain: string
  userDomainSecret: string
  ssid: string
  resetPswStid: string
  loginStid: string
  registerStid: string
  cancelStid: string
  eaid: string
  resetPswEtid: string
  registerEtid: string
  cancelEtid: string
  bootstrapUrl: string
  bootstrapPath: string
  bootstrapToken: string
  saasUrl?: string
}

export interface QuecAppNetworks {
  china: QuecAppNetworkConfig
  europe: QuecAppNetworkConfig
  northAmerica: QuecAppNetworkConfig
}

export interface QuecAppPushConfig {
  aliyunAppId: string
  aliyunSecret: string
  huaweiAppId: string
  oppoAppId: string
  oppoAppKey: string
  vivoAppId: string
  vivoAppKey: string
  miAppId: string
  miAppKey: string
  googleCertificateFile: string
}

export interface QuecAppThirdPlatformConfig {
  sentryDsn: string
  sentryEnv: string
  push: QuecAppPushConfig
  onekeyLoginAppId: string
  onekeyLoginAppKey: string
  onekeyLoginAppSC: string
  onekeyLoginAppIdAndroid: string
  onekeyLoginAppKeyAndroid: string
  aliyunAppId: string
  aliyunSecret: string
  baiduMapKey: string
  baiduMapLocationKey: string
  gaodeMapKey: string
  googleMapKey: string
  googleMapPlaceKey: string
  googlePlaceKey: string
  wxAppId: string
}

export interface QuecAppBusinessConfig {
  isChina: string
  isShowFeedback: string
  isSupportMap: boolean
  androidDebugLogo: string
  androidLaunch: string
  androidLogo: string
  appHelper: string
  appPrivacy: string
  appPrivacyDownloadUrl: string
  appStoreURL: string
  appTab: string
  area: string
  familyHelper: string
  iOSLaunch: string
  iOSLogo: string
  isHomeMode: boolean
  isMatterSupport: boolean
  isMusicModule: boolean
  isQuecApp: boolean
  isQuectel: boolean
  isShowHomeSetting: boolean
  isShowSiri: boolean
  isSupportGooglePush: boolean
  isShowDeviceManager: boolean
  isSupportIPC: boolean
  displayMode: number
  quecTab1Normal: string
  quecTab1Selected: string
  quecTab2Normal: string
  quecTab2Selected: string
  quecTab3Normal: string
  quecTab3Selected: string
  quecThemeConfig: string
  registerLogo: string
  telphone: string
  userPrivacy: string
  quecFeedbackPanel: string
  bssClientAppId: string
  isAddValuesPushSupport: boolean
  isShowPhonePush: boolean
  isShowSmsPush: boolean
  merchantNo: string
  merchantSecret: string
  addValuesPushPanel: number
  isUseDynamicTabIconColor: boolean
  userCenterConfig: string
  avatarsConfig: string
  isHomeList: boolean
  isSupportPaypal: boolean
}

export interface QuecAppTabConfig {
  allowBizPanel: boolean
  bizLabel: string | null
  bizPanelMetaDataField: string | null
  i18nKey: string
  normalMetaDataField: string
  selectedMetaDataField: string
  tabKey: string
  tabOrder: number
  title: string
  normalUrl: string
  selectUrl: string
}

export interface QuecAppConfigData {
  configId: string
  version: string
  platform: string
  basic: QuecAppBasicConfig
  network: QuecAppNetworks
  thirdPlatform: QuecAppThirdPlatformConfig
  business: QuecAppBusinessConfig
  appTabBarConfig: QuecAppTabConfig[]
}
