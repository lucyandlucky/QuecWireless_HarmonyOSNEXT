import { AxiosInstance, InternalAxiosRequestConfig } from '@ohos/axios'
import { QuecHttpLog } from './QuecHttpLog'
import { IQuecRequestInterceptor } from './QuecRequestInterceptor'

export class QuecRequestLogInterceptor implements IQuecRequestInterceptor {
  private readonly client: AxiosInstance
  private readonly log: QuecHttpLog

  constructor(client: AxiosInstance, log: QuecHttpLog) {
    this.client = client
    this.log = log
  }

  public handler(config: InternalAxiosRequestConfig): InternalAxiosRequestConfig {
    try {
      this.log.request(config, this.client.getUri(config))
    } catch (error) {
      // Logging must not change the request outcome.
    }
    return config
  }
}
