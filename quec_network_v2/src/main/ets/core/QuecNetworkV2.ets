import axios, { AxiosInstance, CreateAxiosDefaults, InternalAxiosRequestConfig } from '@ohos/axios'
import { QuecRequestHeaderInterceptor } from '../interceptor/QuecRequestHeaderInterceptor'
import { IQuecRequestInterceptor } from '../interceptor/QuecRequestInterceptor'

export class QuecNetworkV2 {
  private constructor() {
  }

  public static createClient(config: CreateAxiosDefaults): AxiosInstance {
    const client: AxiosInstance = axios.create(config)
    const requestInterceptors: IQuecRequestInterceptor[] = [new QuecRequestHeaderInterceptor()]
    // Axios runs request interceptors in reverse registration order.
    for (let index: number = requestInterceptors.length - 1; index >= 0; index--) {
      const interceptor: IQuecRequestInterceptor = requestInterceptors[index]
      client.interceptors.request.use((request: InternalAxiosRequestConfig) => interceptor.handler(request))
    }
    return client
  }
}
