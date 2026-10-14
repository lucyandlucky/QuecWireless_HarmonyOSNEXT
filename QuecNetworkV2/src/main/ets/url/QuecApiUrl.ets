import { QuecGlobalConfig } from '@quec/oem-app-config'

export class QuecApiUrl {
  /**
   * host 为空（配置未加载成功）时返回原路径，
   * 由 QuecNetworkV2.createRequestConfig 的绝对地址校验统一报错。
   */
  private static join(host: string, path: string): string {
    if (host.length === 0) {
      return path
    }
    return host.replace(/\/+$/, '') + '/' + path.replace(/^\/+/, '')
  }

  public static paas(path: string): string {
    return QuecApiUrl.join(QuecGlobalConfig.network.baseUrl, path)
  }

  public static saas(path: string): string {
    return QuecApiUrl.join(QuecGlobalConfig.network.saasUrl, path)
  }
}
