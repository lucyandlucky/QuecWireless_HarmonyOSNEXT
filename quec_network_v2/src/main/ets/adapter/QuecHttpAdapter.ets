import { JSON } from '@kit.ArkTS'
import { http } from '@kit.NetworkKit'
import { QuecNetworkError, QuecNetworkErrorType } from '../error/QuecNetworkError'
import { QuecRawBody } from '../model/QuecHttpTypes'
import { QuecRequestConfig } from '../model/QuecRequestConfig'
import { QuecRawResponse, QuecResponseHeader } from '../model/QuecResponse'
import { IQuecHttpAdapter } from './IQuecHttpAdapter'
import { QuecPreparedRequest, QuecRequestEncoder } from './QuecRequestEncoder'

export class QuecHttpAdapter implements IQuecHttpAdapter {
  private readonly encoder: QuecRequestEncoder = new QuecRequestEncoder()

  private normalizeBody(result: string | Object | ArrayBuffer | null | undefined, config: QuecRequestConfig): QuecRawBody {
    if (result === null || result === undefined) {
      return ''
    }
    if (typeof result === 'string' || result instanceof ArrayBuffer) {
      return result
    }
    try {
      return JSON.stringify(result)
    } catch (error) {
      throw new QuecNetworkError({
        type: QuecNetworkErrorType.DECODE,
        message: 'Unable to normalize response body',
        config,
        originalError: error as Error
      })
    }
  }

  private normalizeResponse(response: http.HttpResponse, config: QuecRequestConfig): QuecRawResponse {
    const headers: QuecResponseHeader = response.header === null || response.header === undefined
      ? {}
      : response.header as QuecResponseHeader
    return {
      statusCode: Number(response.responseCode),
      headers,
      body: this.normalizeBody(response.result, config)
    }
  }

  private toNetworkError(error: Error | null | undefined, config: QuecRequestConfig): QuecNetworkError {
    if (error instanceof QuecNetworkError) {
      return error
    }
    const source: BusinessError | null | undefined = error as BusinessError | null | undefined
    return new QuecNetworkError({
      type: QuecNetworkErrorType.NETWORK,
      message: source?.message ?? 'Network request failed',
      code: source?.code,
      config,
      originalError: error instanceof Error ? error : undefined
    })
  }

  public async execute(config: QuecRequestConfig): Promise<QuecRawResponse> {
    const prepared: QuecPreparedRequest = this.encoder.encode(config)
    let task: http.HttpRequest | undefined
    try {
      task = http.createHttp()
      const response: http.HttpResponse = await task.request(prepared.url, prepared.options)
      return this.normalizeResponse(response, config)
    } catch (error) {
      throw this.toNetworkError(error as Error | null | undefined, config)
    } finally {
      task?.destroy()
    }
  }
}
