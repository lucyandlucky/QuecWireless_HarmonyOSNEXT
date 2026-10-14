/**
 * 推送平台配置
 */
export class QuecOemPushModel {
  aliKey: string = ''
  aliSecret: string = ''
  huaweiAppId: string = ''
  vivoAppId: string = ''
  vivoAppKey: string = ''
  oppoAppId: string = ''
  oppoAppKey: string = ''
  miAppId: string = ''
  miAppKey: string = ''
}

/**
 * App 三方平台配置信息
 */
export class QuecOemThirdPlatformConfigModel {
  wxAppKey: string = ''
  wxAppSecret: string = ''

  onekeyLoginAppIdAndroid: string = ''
  onekeyLoginAppKeyAndroid: string = ''

  push: QuecOemPushModel = new QuecOemPushModel()

  sentryDsn: string = ''
  sentryEnv: string = ''

  baiduMapKey: string = ''
  gaodeMapKey: string = ''
  googleMapKey: string = ''
  wxAppId: string = ''
  /** Google OAuth 2.0 客户端 ID */
  androidGoogleServerClientID: string = ''
  /** Facebook APP ID */
  facebookLoginAppID: string = ''
  /** Facebook 应用密钥 */
  facebookLoginClientToken: string = ''
  /** Twitter APP ID */
  twitterLoginAppID: string = ''
  /** Twitter API 序号 */
  twitterLoginConsumerKey: string = ''
  /** Twitter API 密钥 */
  twitterLoginConsumerSecret: string = ''
}
