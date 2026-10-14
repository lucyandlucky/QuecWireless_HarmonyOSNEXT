/**
 * Alexa 配置信息
 */
export class QuecAlexaConfig {
  /** Android 端认证路径 */
  androidAuthorizationURI: string = ''
  /** iOS 端认证路径 */
  iosAuthorizationURI: string = ''
  /** Android 重定向 URL */
  androidRedirectURL: string = ''
  /** iOS 重定向 URL */
  iosRedirectURL: string = ''
}

/**
 * Google Assistant 配置信息
 */
export class QuecGoogleAssistantConfig {
  /** iOS 通用链接 */
  iosUniversalLink: string = ''
}

/**
 * 三方语音配置。Android 中由 business.alexaConfig 和 business.googleAssistantConfig 派生，
 * 当前尚未实现派生逻辑。
 */
export class QuecThirdVoiceConfig {
  alexaConfig: QuecAlexaConfig[] | null = null
  googleAssistantConfig: QuecGoogleAssistantConfig | null = null
}
