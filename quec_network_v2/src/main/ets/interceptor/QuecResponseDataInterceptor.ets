import { AxiosResponse } from '@ohos/axios'
import { QuecBusinessError } from '../error/QuecBusinessError'
import { QuecApiResponse } from '../model/QuecApiResponse'
import { QuecAxiosRequestConfig } from '../model/QuecRequestConfig'
import { QuecResponseInterceptor } from './QuecResponseInterceptor'

export class QuecResponseDataInterceptor extends QuecResponseInterceptor {
  public handler(response: AxiosResponse): AxiosResponse {
    if ((response.config as QuecAxiosRequestConfig).quecRawResponse === true) {
      return response
    }
    const payload: Object = response.data as Object
    if (payload === null || typeof payload !== 'object' || Array.isArray(payload)
      || Object.keys(payload).indexOf('code') < 0) {
      throw new Error('Response is not a Quec API response')
    }

    const envelope: QuecApiResponse<Object> = payload as QuecApiResponse<Object>
    if (typeof envelope.code !== 'number') {
      throw new Error('Response code is missing or invalid')
    }
    if (envelope.code !== 200) {
      const message: string = typeof envelope.msg === 'string' ? envelope.msg : ''
      const subCode: number = typeof envelope.subCode === 'number' ? envelope.subCode : -1
      throw new QuecBusinessError(envelope.code, message, subCode)
    }

    return response
  }
}
