import { InternalAxiosRequestConfig } from '@ohos/axios'
import { QuecMmkvManager } from 'quec_mmkv'
import { QuecTokenManager } from '../token/QuecTokenManager'
import { IQuecRequestInterceptor } from './QuecRequestInterceptor'

export class QuecRequestTokenInterceptor implements IQuecRequestInterceptor {
  public handler(config: InternalAxiosRequestConfig): InternalAxiosRequestConfig {
    if (config.headers.has('Authorization') || !QuecMmkvManager.isInitialized()) {
      return config
    }
    const token: string = QuecTokenManager.getAccessToken()
    if (token.trim().length > 0) {
      config.headers.set('Authorization', token)
    }
    return config
  }
}
