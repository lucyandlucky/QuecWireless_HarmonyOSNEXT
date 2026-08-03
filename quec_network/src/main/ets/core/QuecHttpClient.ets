import { QuecNetworkConfig } from '../config/QuecNetworkConfig';
import { QuecNetworkConstants } from '../constants/QuecNetworkConstants';
import { QuecNetworkError, QuecNetworkErrorType } from '../error/QuecNetworkError';
import { QuecRawResponse } from '../model/QuecRawResponse';
import { QuecRequestMethod } from '../model/QuecRequestMethod';
import { QuecRequestBody, QuecRequestOptions } from '../model/QuecRequestOptions';
import { QuecResponseParser } from '../parser/QuecResponseParser';
import { QuecHttpTransport } from '../transport/QuecHttpTransport';

export class QuecHttpClient {
  private readonly config: QuecNetworkConfig
  private readonly transport: QuecHttpTransport
  private readonly parser: QuecResponseParser

  constructor(config: QuecNetworkConfig) {
    this.config = config
    this.transport = new QuecHttpTransport()
    this.parser = new QuecResponseParser()
  }

  public async get<T>(url: string, options?: QuecRequestOptions) {
    return this.request<T>(url, QuecRequestMethod.GET, undefined, options)
  }

  public async post<T>(url: string, body?: QuecRequestBody, options?: QuecRequestOptions) {
    return this.request<T>(url, QuecRequestMethod.POST, body, options)
  }

  public async requestRaw(
    url: string,
    method: QuecRequestMethod,
    body?: QuecRequestBody,
    options?: QuecRequestOptions
  ): Promise<QuecRawResponse> {
    return this.transport.request(
      this.resolveUrl(url),
      method,
      body,
      this.mergeOptions(options)
    )
  }

  public async requestWithoutData(
    url: string,
    method: QuecRequestMethod,
    body?: QuecRequestBody,
    options?: QuecRequestOptions
  ): Promise<void> {
    const response: QuecRawResponse = await this.requestRaw(url, method, body, options)
    this.parser.parseWithoutData(response)
  }

  public async request<T>(
    url: string,
    method: QuecRequestMethod,
    body?: QuecRequestBody,
    options?: QuecRequestOptions
  ): Promise<T> {
    const response: QuecRawResponse = await this.requestRaw(url, method, body, options)
    return this.parser.parse<T>(response)
  }

  private illegalRequest(message: string): QuecNetworkError {
    return new QuecNetworkError(
      QuecNetworkErrorType.REQUEST_ILLEGAL,
      QuecNetworkConstants.UNKNOWN_ERROR_CODE,
      message
    )
  }

  private resolveUrl(url: string): string {
    const requestUrl: string = url.trim()
    if (requestUrl.length === 0) {
      throw this.illegalRequest('Request URL cannot be empty')
    }

    const lowerUrl: string = requestUrl.toLowerCase()
    if (lowerUrl.startsWith('http://') || lowerUrl.startsWith('https://')) {
      return requestUrl
    }

    const baseUrl: string = this.config.baseUrl.trim()
    const lowerBaseUrl: string = baseUrl.toLowerCase()
    if (!lowerBaseUrl.startsWith('http://') && !lowerBaseUrl.startsWith('https://')) {
      throw this.illegalRequest('baseUrl must start with http:// or https://')
    }

    const normalizedBaseUrl: string = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl
    const normalizedPath: string = requestUrl.startsWith('/') ? requestUrl : `/${requestUrl}`

    return `${normalizedBaseUrl}${normalizedPath}`
  }

  private mergeOptions(options?: QuecRequestOptions): QuecRequestOptions {
    return {
      headers: options?.headers,
      queryParams: options?.queryParams,
      formBody: options?.formBody,
      connectTimeout: options?.connectTimeout ?? this.config.connectTimeout,
      readTimeout: options?.readTimeout ?? this.config.readTimeout
    }
  }
}