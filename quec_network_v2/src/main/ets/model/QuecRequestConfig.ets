import {
  QuecBodyFormat,
  QuecHeaders,
  QuecQueryParams,
  QuecRequestBody,
  QuecRequestMethod,
  QuecResponseType
} from './QuecHttpTypes'

export interface QuecRequestOptions {
  url: string
  params?: QuecQueryParams
  body?: QuecRequestBody
  bodyFormat?: QuecBodyFormat
  responseType?: QuecResponseType
  headers?: QuecHeaders
  connectTimeout?: number
  readTimeout?: number
}

export interface QuecRequestConfig extends QuecRequestOptions {
  method: QuecRequestMethod
}
