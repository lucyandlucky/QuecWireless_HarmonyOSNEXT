import { http } from '@kit.NetworkKit';
import { QuecRawResponse } from '../model/QuecRawResponse';
import { QuecRequestMethod } from '../model/QuecRequestMethod';
import { QuecFormBody, QuecHeaders, QuecRequestBody, QuecRequestOptions } from '../model/QuecRequestOptions';
import { QuecNetworkConstants } from '../constants/QuecNetworkConstants';
import { QuecNetworkError, QuecNetworkErrorType } from '../error/QuecNetworkError';

export class QuecHttpTransport {
  private toNativeMethod(method: QuecRequestMethod): http.RequestMethod {
    switch (method) {
      case QuecRequestMethod.GET:
        return http.RequestMethod.GET
      case QuecRequestMethod.POST:
        return http.RequestMethod.POST
      case QuecRequestMethod.PUT:
        return http.RequestMethod.PUT
      case QuecRequestMethod.DELETE:
        return http.RequestMethod.DELETE
      case QuecRequestMethod.PATCH:
        return http.RequestMethod.PATCH
    }
  }

  private encodeForm(formBody: QuecFormBody): string {
    return Object.keys(formBody)
      .map((key: string) => `${encodeURIComponent(key)}=${encodeURIComponent(formBody[key])}`)
      .join('&')
  }

  private createHeader(options?: QuecRequestOptions): QuecHeaders {
    const headers: QuecHeaders = {}
    headers[QuecNetworkConstants.HEADER_CONTENT_TYPE] = QuecNetworkConstants.CONTENT_TYPE_JSON
    const customHeaders: QuecHeaders | undefined = options?.headers
    if (customHeaders !== undefined) {
      Object.keys(customHeaders).forEach((key: string) => {
        headers[key] = customHeaders[key]
      })
    }
    if (options?.formBody !== undefined) {
      headers[QuecNetworkConstants.HEADER_CONTENT_TYPE] = QuecNetworkConstants.CONTENT_TYPE_FORM
    }
    return headers
  }

  private createOptions(
    method: QuecRequestMethod,
    body?: QuecRequestBody,
    options?: QuecRequestOptions
  ): http.HttpRequestOptions {
    if (body !== undefined && options?.formBody !== undefined) {
      throw new QuecNetworkError(QuecNetworkErrorType.REQUEST_ILLEGAL, -1, 'body and formBody cannot be use together')
    }

    const nativeOptions: http.HttpRequestOptions = {
      method: this.toNativeMethod(method),
      header: this.createHeader(options),
      connectTimeout: options?.connectTimeout ?? QuecNetworkConstants.DEFAULT_CONNECT_TIMEOUT_MS,
      readTimeout: options?.readTimeout ?? QuecNetworkConstants.DEFAULT_READ_TIMEOUT_MS,
      expectDataType: http.HttpDataType.STRING,
      usingCache: false
    }

    if (options?.queryParams !== undefined) {
      nativeOptions.queryParams = options.queryParams
    }

    if (options?.formBody !== undefined) {
      nativeOptions.body = this.encodeForm(options.formBody)
    } else if (body !== undefined) {
      nativeOptions.body = body
    }

    return nativeOptions
  }


  async request(
    url: string,
    method: QuecRequestMethod,
    body?: QuecRequestBody,
    options?: QuecRequestOptions
  ): Promise<QuecRawResponse> {
    const task: http.HttpRequest = http.createHttp()
    try {
      const response: http.HttpResponse = await task.request(
        url,
        this.createOptions(method, body, options)
      )

      return {
        statusCode: Number(response.responseCode),
        body: response.result as string,
        headers: response.header
      }

    } catch (error) {
      if (error instanceof QuecNetworkError) {
        throw error
      }
      const source: BusinessError = error as BusinessError
      throw new QuecNetworkError(
        QuecNetworkErrorType.NETWORK_ERROR,
        source.code ?? -1,
        source.message ?? 'Network request failed',
        QuecNetworkConstants.DEFAULT_SUB_CODE,
        source
      )
    } finally {
      task.destroy()
    }
  }
}