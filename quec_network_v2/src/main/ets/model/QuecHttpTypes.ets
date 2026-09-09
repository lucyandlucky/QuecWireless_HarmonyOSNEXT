export type QuecHeaders = Record<string, string>

export type QuecQueryValue = string | number | boolean

export type QuecQueryParams = Record<string, QuecQueryValue | QuecQueryValue[]>

export type QuecRequestBody = string | Object | ArrayBuffer

export type QuecRawBody = string | ArrayBuffer

export enum QuecRequestMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE'
}