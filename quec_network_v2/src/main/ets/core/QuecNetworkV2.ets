import axios, {
  AxiosHeaders,
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  CreateAxiosDefaults,
  InternalAxiosRequestConfig
} from '@ohos/axios'
import { QuecRequestHeaderInterceptor } from '../interceptor/QuecRequestHeaderInterceptor'
import { IQuecRequestInterceptor } from '../interceptor/QuecRequestInterceptor'
import { QuecResponseDataInterceptor } from '../interceptor/QuecResponseDataInterceptor'
import { IQuecResponseInterceptor, QuecRawResponseConfig } from '../interceptor/QuecResponseInterceptor'
import { QuecApiResponse } from '../model/QuecApiResponse'

// ArkTS accepts inline {} through declared interfaces; populated objects need concrete caller types.
export interface QuecRequestParams {}

export interface QuecRequestBody {}

export interface QuecRequestOptions {
  url: string
  params?: QuecRequestParams
  body?: QuecRequestBody | string | ArrayBuffer
  headers?: AxiosHeaders
  timeout?: number
}

export interface QuecRawRequestOptions extends QuecRequestOptions {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE'
}

export class QuecNetworkV2 {
  private static sharedClient?: QuecNetworkV2
  private client: AxiosInstance
  private static readonly requestInterceptors: IQuecRequestInterceptor[] = [
    new QuecRequestHeaderInterceptor()
  ]
  private static readonly responseInterceptors: IQuecResponseInterceptor[] = [
    new QuecResponseDataInterceptor()
  ]

  private constructor(client: AxiosInstance) {
    this.client = client
  }

  private static createClient(config: CreateAxiosDefaults): AxiosInstance {
    const client: AxiosInstance = axios.create(config)
    // Axios runs request interceptors in reverse registration order.
    for (let i: number = QuecNetworkV2.requestInterceptors.length - 1; i >= 0; i--) {
      const interceptor: IQuecRequestInterceptor = QuecNetworkV2.requestInterceptors[i]
      client.interceptors.request.use((request: InternalAxiosRequestConfig) => interceptor.handler(request))
    }
    for (let i: number = 0; i < QuecNetworkV2.responseInterceptors.length; i++) {
      const interceptor: IQuecResponseInterceptor = QuecNetworkV2.responseInterceptors[i]
      client.interceptors.response.use((response: AxiosResponse) => interceptor.handler(response))
    }
    return client
  }

  private createRequestConfig(method: string, options: QuecRequestOptions): AxiosRequestConfig {
    return {
      method,
      url: options.url,
      params: options.params,
      data: options.body,
      headers: options.headers,
      timeout: options.timeout
    }
  }

  private async request<T>(method: string, options: QuecRequestOptions): Promise<QuecApiResponse<T>> {
    const response: AxiosResponse<QuecApiResponse<T>> = await this.client.request<QuecApiResponse<T>>(
      this.createRequestConfig(method, options)
    )
    return response.data
  }

  public static init(config: CreateAxiosDefaults): void {
    const client: AxiosInstance = QuecNetworkV2.createClient(config)
    const sharedClient: QuecNetworkV2 | undefined = QuecNetworkV2.sharedClient
    if (sharedClient === undefined) {
      QuecNetworkV2.sharedClient = new QuecNetworkV2(client)
    } else {
      sharedClient.client = client
    }
  }

  public static getClient(): QuecNetworkV2 {
    const client: QuecNetworkV2 | undefined = QuecNetworkV2.sharedClient
    if (client === undefined) {
      throw new Error('Call QuecNetworkV2.init before getting the network client')
    }
    return client
  }

  public get<T = Object>(options: QuecRequestOptions): Promise<QuecApiResponse<T>> {
    return this.request<T>('GET', options)
  }

  public post<T = Object>(options: QuecRequestOptions): Promise<QuecApiResponse<T>> {
    return this.request<T>('POST', options)
  }

  public put<T = Object>(options: QuecRequestOptions): Promise<QuecApiResponse<T>> {
    return this.request<T>('PUT', options)
  }

  public delete<T = Object>(options: QuecRequestOptions): Promise<QuecApiResponse<T>> {
    return this.request<T>('DELETE', options)
  }

  public requestRaw<T = Object>(options: QuecRawRequestOptions): Promise<AxiosResponse<T>> {
    const config: QuecRawResponseConfig = this.createRequestConfig(options.method, options)
    config.quecRawResponse = true
    return this.client.request<T>(config)
  }
}
