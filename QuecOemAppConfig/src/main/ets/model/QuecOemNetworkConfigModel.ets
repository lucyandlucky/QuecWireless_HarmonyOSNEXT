/**
 * App 网络配置信息
 */
export class QuecOemNetworkConfigModel {
  environment: string = ''
  baseUrl: string = ''
  webSocketUrl: string = ''
  webSocketV2Url: string = ''
  saasUrl: string = ''
  userDomain: string = ''
  userDomainSecret: string = ''

  ssid: string = ''
  resetPswStid: string = ''
  loginStid: string = ''
  registerStid: string = ''
  cancelStid: string = ''

  eaid: string = ''
  resetPswEtid: string = ''
  registerEtid: string = ''
  cancelEtid: string = ''
  bootstrapUrl: string = ''
  bootstrapPath: string = ''
  bootstrapToken: string = ''
}

/**
 * 各区域网络配置
 */
export class QuecOemNetwork {
  china: QuecOemNetworkConfigModel = new QuecOemNetworkConfigModel()
  europe: QuecOemNetworkConfigModel = new QuecOemNetworkConfigModel()
  northAmerica: QuecOemNetworkConfigModel = new QuecOemNetworkConfigModel()
}
