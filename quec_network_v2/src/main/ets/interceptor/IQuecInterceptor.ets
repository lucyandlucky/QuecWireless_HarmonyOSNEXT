import { QuecNetworkError } from '../error/QuecNetworkError'

export type QuecInterceptorResult<T> = T | Promise<T>

export type QuecInterceptorFulfilled<T> = (value: T) => QuecInterceptorResult<T>

export type QuecInterceptorRejected<T> = (error: QuecNetworkError) => QuecInterceptorResult<T>

export interface QuecInterceptorHandler<T> {
  readonly id: number
  readonly onFulfilled: QuecInterceptorFulfilled<T>
  readonly onRejected?: QuecInterceptorRejected<T>
}