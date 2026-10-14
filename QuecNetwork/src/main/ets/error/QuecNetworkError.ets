import { QuecNetworkConstants } from '../constants/QuecNetworkConstants'

export enum QuecNetworkErrorType {
  COMMON = 'COMMON',
  DATA_NULL = 'DATA_NULL',
  NETWORK_ERROR = 'NETWORK_ERROR',
  REQUEST_ILLEGAL = 'REQUEST_ILLEGAL',
  HTTP_ERROR = 'HTTP_ERROR',
  PARSE_ERROR = 'PARSE_ERROR'
}

export class QuecNetworkError extends Error {
  readonly type: QuecNetworkErrorType
  readonly code: number
  readonly subCode: number
  readonly originalError?: Error

  constructor(
    type: QuecNetworkErrorType,
    code: number,
    message: string,
    subCode: number = QuecNetworkConstants.DEFAULT_SUB_CODE,
    originalError?: Error
  ) {
    super(message)
    this.type = type
    this.code = code
    this.subCode = subCode
    this.originalError = originalError
  }
}
