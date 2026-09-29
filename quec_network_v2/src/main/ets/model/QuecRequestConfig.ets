import { AxiosRequestConfig } from '@ohos/axios'

export type QuecFormBody = Record<string, string>

export interface QuecAxiosRequestConfig extends AxiosRequestConfig {
  quecFormBody?: boolean
  quecRawResponse?: boolean
}
