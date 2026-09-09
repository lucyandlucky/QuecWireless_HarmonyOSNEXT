import { QuecRawBody } from './QuecHttpTypes'
import { QuecRequestConfig } from './QuecRequestConfig'

export type QuecResponseHeaderValue = string | string[]

export type QuecResponseHeader = Record<string, QuecResponseHeaderValue>

export interface QuecRawResponse {
  statusCode: number
  headers: QuecResponseHeader
  body: QuecRawBody
}

export interface QuecResponse<T> {
  statusCode: number
  headers: QuecResponseHeader
  data: T
  config: QuecRequestConfig
}