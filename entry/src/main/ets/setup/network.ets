import { AxiosHeaders, QuecNetworkV2 } from '@quec/network-v2'
import { QuecGlobalConfig } from '@quec/oem-app-config'

const APP_SYSTEM_TYPE: string = 'harmony'

/** 公共请求头走 axios defaults，不需要改拦截器 */
function commonHeaders(): AxiosHeaders {
  const headers: AxiosHeaders = new AxiosHeaders()
  headers.set('appVersion', QuecGlobalConfig.basic.appVersion)
  headers.set('appSystemType', APP_SYSTEM_TYPE)
  headers.set('appId', QuecGlobalConfig.configId.toString())
  return headers
}

/**
 * 不配置 baseURL：各接口用 QuecApiUrl 拼完整地址，这样同一个客户端可以访问
 * PaaS 和 SaaS 等不同 host。
 */
export function setupNetwork(): void {
  QuecNetworkV2.init({ headers: commonHeaders() })
}
