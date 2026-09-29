import axios, {
  AxiosHeaders,
  AxiosInstance,
  AxiosResponse,
  CreateAxiosDefaults,
  InternalAxiosRequestConfig
} from '@ohos/axios'
import { QuecRequestHeaderInterceptor } from '../interceptor/QuecRequestHeaderInterceptor'
import { QuecHttpLog } from '../interceptor/QuecHttpLog'
import { IQuecRequestInterceptor } from '../interceptor/QuecRequestInterceptor'
import { QuecRequestLogInterceptor } from '../interceptor/QuecRequestLogInterceptor'
import { QuecRequestTokenInterceptor } from '../interceptor/QuecRequestTokenInterceptor'
import { QuecResponseDataInterceptor } from '../interceptor/QuecResponseDataInterceptor'
import { IQuecResponseInterceptor } from '../interceptor/QuecResponseInterceptor'
import { QuecResponseLogInterceptor } from '../interceptor/QuecResponseLogInterceptor'
import { QuecApiResponse } from '../model/QuecApiResponse'
import { QuecAxiosRequestConfig, QuecFormBody } from '../model/QuecRequestConfig'

// ArkTS accepts inline {} through declared interfaces; populated objects need concrete caller types.
export interface QuecRequestParams {}

export interface QuecRequestBody {}

export interface QuecRequestOptions {
  url: string
  params?: QuecRequestParams
  body?: QuecRequestBody | string | ArrayBuffer
  formBody?: QuecFormBody
  headers?: AxiosHeaders
  timeout?: number
}

export interface QuecRawRequestOptions extends QuecRequestOptions {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE'
}

export class QuecNetworkV2 {
  private static sharedClient?: QuecNetworkV2
  private client: AxiosInstance

  private constructor(client: AxiosInstance) {
    this.client = client
  }

  private static createClient(config: CreateAxiosDefaults): AxiosInstance {
    const client: AxiosInstance = axios.create(config)
    const log: QuecHttpLog = new QuecHttpLog()
    const requestInterceptors: IQuecRequestInterceptor[] = [
      new QuecRequestHeaderInterceptor(),
      new QuecRequestTokenInterceptor(),
      new QuecRequestLogInterceptor(client, log)
    ]
    const responseInterceptors: IQuecResponseInterceptor[] = [
      new QuecResponseLogInterceptor(log),
      new QuecResponseDataInterceptor()
    ]
    // Axios runs request interceptors in reverse registration order.
    for (let i: number = requestInterceptors.length - 1; i >= 0; i--) {
      const interceptor: IQuecRequestInterceptor = requestInterceptors[i]
      client.interceptors.request.use((request: InternalAxiosRequestConfig) => interceptor.handler(request))
    }
    for (let i: number = 0; i < responseInterceptors.length; i++) {
      const interceptor: IQuecResponseInterceptor = responseInterceptors[i]
      client.interceptors.response.use(
        (response: AxiosResponse) => interceptor.handler(response),
        (error: Error) => interceptor.onError(error)
      )
    }
    return client
  }

  private createRequestConfig(method: string, options: QuecRequestOptions): QuecAxiosRequestConfig {
    if (options.body !== undefined && options.formBody !== undefined) {
      throw new Error('Specify either body or formBody')
    }
    return {
      method,
      url: options.url,
      params: options.params,
      data: options.formBody !== undefined ? options.formBody : options.body,
      quecFormBody: options.formBody !== undefined,
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
    const config: QuecAxiosRequestConfig = this.createRequestConfig(options.method, options)
    config.quecRawResponse = true
    return this.client.request<T>(config)
  }
}
