export type QuecHeaders = Record<string, string>

export type QuecQueryValue = string | number | boolean

export type QuecQueryParams = Record<string, QuecQueryValue | QuecQueryValue[]>

export type QuecFormBody = Record<string, string>

export type QuecRequestBody = string | Object | ArrayBuffer

export interface QuecRequestOptions {
  headers?: QuecHeaders
  queryParams?: QuecQueryParams | string
  formBody?: QuecFormBody
  connectTimeout?: number
  readTimeout?: number
}
