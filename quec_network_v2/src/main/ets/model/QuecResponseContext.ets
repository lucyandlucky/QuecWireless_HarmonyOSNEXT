import { QuecRawBody } from './QuecHttpTypes'
import { QuecRequestConfig } from './QuecRequestConfig'
import { QuecResponseHeader } from './QuecResponse'

export type QuecResponseData = string | number | boolean | Object | ArrayBuffer | null | undefined

export interface QuecResponseContext {
  readonly statusCode: number
  readonly headers: QuecResponseHeader
  readonly rawBody: QuecRawBody
  readonly data: QuecResponseData
  readonly config: QuecRequestConfig
}