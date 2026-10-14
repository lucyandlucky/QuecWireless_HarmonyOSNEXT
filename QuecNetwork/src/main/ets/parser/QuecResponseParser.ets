import { QuecApiResponse } from '../model/QuecApiResponse';
import { JSON } from '@kit.ArkTS';
import { QuecNetworkError, QuecNetworkErrorType } from '../error/QuecNetworkError';
import { QuecNetworkConstants } from '../constants/QuecNetworkConstants';
import { QuecRawResponse } from '../model/QuecRawResponse';

export class QuecResponseParser {
  private parseEnvelope<T>(body: string): QuecApiResponse<T> {
    try {
      const parsed: Object | null = JSON.parse(body)
      if (parsed === null) {
        throw new Error('Response body is null')
      }

      const result: QuecApiResponse<T> = parsed as QuecApiResponse<T>

      if (typeof result.code !== 'number') {
        throw new Error('Response code is missing or invalid')
      }

      return result

    } catch (error) {
      const source: Error = error as Error
      throw new QuecNetworkError(
        QuecNetworkErrorType.PARSE_ERROR,
        QuecNetworkConstants.UNKNOWN_ERROR_CODE,
        source.message ?? 'Invalid response JSON',
        QuecNetworkConstants.DEFAULT_SUB_CODE,
        source
      )
    }
  }

  private checkHttpStatus(response: QuecRawResponse): void {
    if (response.statusCode < QuecNetworkConstants.HTTP_SUCCESS_MIN_CODE
      || response.statusCode > QuecNetworkConstants.HTTP_SUCCESS_MAX_CODE) {
      throw new QuecNetworkError(
        QuecNetworkErrorType.HTTP_ERROR,
        response.statusCode,
        `HTTP request failed with status ${response.statusCode}`
      )
    }
  }

  public parseWithoutData(response: QuecRawResponse): void {
    this.checkHttpStatus(response)

    const result: QuecApiResponse<Object> = this.parseEnvelope<Object>(response.body)

    if (result.code !== QuecNetworkConstants.BUSINESS_SUCCESS_CODE) {
      throw new QuecNetworkError(
        QuecNetworkErrorType.COMMON,
        result.code,
        result.msg ?? '',
        result.subCode ?? QuecNetworkConstants.DEFAULT_SUB_CODE
      )
    }
  }

  public parse<T>(response: QuecRawResponse): T {
    this.checkHttpStatus(response)

    const result: QuecApiResponse<T> = this.parseEnvelope(response.body)

    if (result.code !== QuecNetworkConstants.BUSINESS_SUCCESS_CODE) {
      throw new QuecNetworkError(
        QuecNetworkErrorType.COMMON,
        result.code,
        result.msg ?? '',
        result.subCode ?? QuecNetworkConstants.DEFAULT_SUB_CODE
      )
    }

    if (result.data === null || result.data === undefined) {
      throw new QuecNetworkError(
        QuecNetworkErrorType.DATA_NULL,
        result.code,
        result.msg ?? 'Response data is empty',
        result.subCode ?? QuecNetworkConstants.DEFAULT_SUB_CODE
      )
    }
    return result.data
  }
}
