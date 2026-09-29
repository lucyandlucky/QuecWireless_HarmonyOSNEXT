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

export class QuecNetworkV2 {
  private static sharedClient?: QuecNetworkV2
  private client: AxiosInstance
  private static readonly requestInterceptors: IQuecRequestInterceptor[] = [
    new QuecRequestHeaderInterceptor()
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
    return client
  }

  private request<T>(method: string, options: QuecRequestOptions): Promise<AxiosResponse<T>> {
    const config: AxiosRequestConfig = {
      method,
      url: options.url,
      params: options.params,
      data: options.body,
      headers: options.headers,
      timeout: options.timeout
    }
    return this.client.request<T>(config)
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

  public get<T = Object>(options: QuecRequestOptions): Promise<AxiosResponse<T>> {
    return this.request<T>('GET', options)
  }

  public post<T = Object>(options: QuecRequestOptions): Promise<AxiosResponse<T>> {
    return this.request<T>('POST', options)
  }

  public put<T = Object>(options: QuecRequestOptions): Promise<AxiosResponse<T>> {
    return this.request<T>('PUT', options)
  }

  public delete<T = Object>(options: QuecRequestOptions): Promise<AxiosResponse<T>> {
    return this.request<T>('DELETE', options)
  }
}
