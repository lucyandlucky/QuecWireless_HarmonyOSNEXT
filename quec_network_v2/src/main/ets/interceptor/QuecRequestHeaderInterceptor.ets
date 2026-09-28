import { InternalAxiosRequestConfig } from '@ohos/axios'
import { IQuecRequestInterceptor } from './QuecRequestInterceptor'

export class QuecRequestHeaderInterceptor implements IQuecRequestInterceptor {
  public handler(config: InternalAxiosRequestConfig): InternalAxiosRequestConfig {
    if (!config.headers.has('Content-Type')) {
      config.headers.set('Content-Type', 'application/json')
    }
    if (!config.headers.has('X-Q-language')) {
      config.headers.set('X-Q-language', 'zh_CN')
    }
    return config
  }
}
