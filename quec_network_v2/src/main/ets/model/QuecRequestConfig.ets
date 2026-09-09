import { QuecHeaders, QuecQueryParams, QuecRequestBody, QuecRequestMethod } from './QuecHttpTypes'

export interface QuecRequestOptions {
  url: string
  params?: QuecQueryParams,
  body?: QuecRequestBody
  headers?: QuecHeaders,
  connectTimeout?: number,
  readTimeout?: number
}

export interface QuecRequestConfig extends QuecRequestOptions {
  method: QuecRequestMethod
}