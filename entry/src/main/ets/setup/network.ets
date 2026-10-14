import { AxiosHeaders, QuecNetworkV2 } from '@quec/network-v2'
import { QuecGlobalConfig } from '@quec/oem-app-config'

const APP_SYSTEM_TYPE: string = 'harmony'

/** 公共请求头走 axios defaults，这样 @quec/network-v2 不需要依赖 @quec/oem-app-config */
function commonHeaders(): AxiosHeaders {
  const headers: AxiosHeaders = new AxiosHeaders()
  headers.set('appVersion', QuecGlobalConfig.basic.appVersion)
  headers.set('appSystemType', APP_SYSTEM_TYPE)
  headers.set('appId', QuecGlobalConfig.configId.toString())
  return headers
}

export function setupNetwork(): void {
  QuecNetworkV2.init({
    baseURL: QuecGlobalConfig.network.baseUrl,
    headers: commonHeaders()
  })
}
