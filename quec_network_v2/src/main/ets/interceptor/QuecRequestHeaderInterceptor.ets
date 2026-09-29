import { InternalAxiosRequestConfig } from '@ohos/axios'
import { QuecAxiosRequestConfig } from '../model/QuecRequestConfig'
import { IQuecRequestInterceptor } from './QuecRequestInterceptor'

export class QuecRequestHeaderInterceptor implements IQuecRequestInterceptor {
  public handler(config: InternalAxiosRequestConfig): InternalAxiosRequestConfig {
    if ((config as QuecAxiosRequestConfig).quecFormBody) {
      config.headers.setContentType('application/x-www-form-urlencoded')
    } else if (!config.headers.has('Content-Type')) {
      config.headers.set('Content-Type', 'application/json')
    }
    if (!config.headers.has('X-Q-language')) {
      config.headers.set('X-Q-language', 'zh_CN')
    }
    return config
  }
}
