import { QuecHeaders } from '../model/QuecRequestOptions'

export interface QuecNetworkConfig {
  baseUrl: string
  appId: string
  appVersion: string
  appSystemType: string
  connectTimeout?: number
  readTimeout?: number
  debug?: boolean
  languageProvider: () => string
  appInfoProvider: () => string
  defaultHeaders?: QuecHeaders
}