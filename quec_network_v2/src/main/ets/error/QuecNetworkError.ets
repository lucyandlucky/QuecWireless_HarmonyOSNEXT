import { QuecRequestConfig } from '../model/QuecRequestConfig'
import { QuecRawResponse } from '../model/QuecResponse'

const UNKNOWN_ERROR_CODE: number = -1

export enum QuecNetworkErrorType {
  INVALID_CONFIG = 'INVALID_CONFIG',
  NETWORK = 'NETWORK',
  HTTP = 'HTTP',
  DECODE = 'DECODE',
  BUSINESS = 'BUSINESS',
  UNKNOWN = 'UNKNOWN'
}

export interface QuecNetworkErrorOptions {
  type: QuecNetworkErrorType
  message: string
  code?: number
  subCode?: number
  config?: QuecRequestConfig
  response?: QuecRawResponse
  originalError?: Error
}

export class QuecNetworkError extends Error {
  readonly TAG: string = 'QuecNetworkError'
  readonly type: QuecNetworkErrorType
  readonly code: number
  readonly subCode: number
  readonly config?: QuecRequestConfig
  readonly response?: QuecRawResponse
  readonly originalError?: Error

  constructor(options: QuecNetworkErrorOptions) {
    super(options.message)

    this.name = this.TAG
    this.type = options.type
    this.code = options.code ?? UNKNOWN_ERROR_CODE
    this.subCode = options.subCode ?? UNKNOWN_ERROR_CODE
    this.config = options.config
    this.response = options.response
    this.originalError = options.originalError
  }
}