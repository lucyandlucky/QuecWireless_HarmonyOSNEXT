import { QuecHeaders } from '../model/QuecHttpTypes'

export interface QuecClientConfig {
  baseUrl: string
  headers?: QuecHeaders
  connectTimeout?: number
  readTimeout?: number
  debug?: boolean
}