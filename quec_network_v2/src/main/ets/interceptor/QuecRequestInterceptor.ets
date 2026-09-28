import { InternalAxiosRequestConfig } from '@ohos/axios'

export interface IQuecRequestInterceptor {
  handler(config: InternalAxiosRequestConfig): InternalAxiosRequestConfig | Promise<InternalAxiosRequestConfig>
}
