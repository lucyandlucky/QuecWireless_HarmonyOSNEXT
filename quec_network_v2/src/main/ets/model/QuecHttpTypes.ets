export type QuecHeaders = Record<string, string>

export type QuecQueryValue = string | number | boolean

export type QuecQueryParams = Record<string, QuecQueryValue | QuecQueryValue[]>

export type QuecFormBody = Record<string, string>

export type QuecRequestBody = string | Object | ArrayBuffer

export type QuecRawBody = string | ArrayBuffer

export enum QuecBodyFormat {
  JSON = 'json',
  FORM = 'form',
  RAW = 'raw'
}

export enum QuecResponseType {
  JSON = 'json',
  TEXT = 'text',
  ARRAY_BUFFER = 'arrayBuffer'
}

export enum QuecRequestMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE'
}
