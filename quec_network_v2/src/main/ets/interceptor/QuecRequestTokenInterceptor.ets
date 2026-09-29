import { InternalAxiosRequestConfig } from '@ohos/axios'
import { QuecMmkvManager } from 'quec_mmkv'
import { IQuecRequestInterceptor } from './QuecRequestInterceptor'

export class QuecRequestTokenInterceptor implements IQuecRequestInterceptor {
  private static readonly TOKEN_SCOPE: string = 'quec_network'
  private static readonly ACCESS_TOKEN_KEY: string = 'access_token'

  public handler(config: InternalAxiosRequestConfig): InternalAxiosRequestConfig {
    if (config.headers.has('Authorization') || !QuecMmkvManager.isInitialized()) {
      return config
    }
    const token: string = QuecMmkvManager
      .getInstance(QuecRequestTokenInterceptor.TOKEN_SCOPE)
      .getString(QuecRequestTokenInterceptor.ACCESS_TOKEN_KEY)
    if (token.trim().length > 0) {
      config.headers.set('Authorization', token)
    }
    return config
  }
}
