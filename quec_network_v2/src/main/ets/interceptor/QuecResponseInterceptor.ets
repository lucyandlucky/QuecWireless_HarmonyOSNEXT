import { AxiosRequestConfig, AxiosResponse } from '@ohos/axios'

export interface QuecRawResponseConfig extends AxiosRequestConfig {
  quecRawResponse?: boolean
}

export interface IQuecResponseInterceptor {
  handler(response: AxiosResponse): AxiosResponse | Promise<AxiosResponse>
}
