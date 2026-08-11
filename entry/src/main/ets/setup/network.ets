import { bundleManager } from '@kit.AbilityKit'
import { deviceInfo } from '@kit.BasicServicesKit'
import { i18n } from '@kit.LocalizationKit'
import { QuecNetwork, QuecNetworkConfig, QuecNetworkConstants } from 'quec_network'

const BASE_URL: string = 'https://iot-api.quectelcn.com'
const APP_ID: string = '271'
const APP_SYSTEM_TYPE: string = 'harmony'

function getAppVersion() {
  const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
  return bundleInfo.versionName
}

function getAppInfo(): string {
  return `[${deviceInfo.productModel}]` +
    `[${deviceInfo.manufacture}]` +
    `[${deviceInfo.productSeries}]` +
    `[${deviceInfo.sdkApiVersion}]`
}

function getNetworkLanguage(): string {
  const language = i18n.System
    .getAppPreferredLanguage()
    .replace('_', '-')
    .toLowerCase()

  if (language.startsWith('zh-hant') ||
    language.startsWith('zh-tw') ||
    language.startsWith('zh-hk') ||
    language.startsWith('zh-mo')) {
    return QuecNetworkConstants.LANGUAGE_HANT
  }

  if (language.startsWith('zh')) {
    return QuecNetworkConstants.LANGUAGE_CN
  }

  return QuecNetworkConstants.LANGUAGE_EN
}

export function setupNetwork(): void {
  const config: QuecNetworkConfig = {
    baseUrl: BASE_URL,
    appId: APP_ID,
    appVersion: getAppVersion(),
    appSystemType: APP_SYSTEM_TYPE,
    languageProvider: getNetworkLanguage,
    appInfoProvider: getAppInfo
  }

  QuecNetwork.initialize(config)
}
