import { AxiosResponse } from '@ohos/axios'
import { QuecHttpLog } from './QuecHttpLog'
import { QuecResponseInterceptor } from './QuecResponseInterceptor'

export class QuecResponseLogInterceptor extends QuecResponseInterceptor {
  private readonly log: QuecHttpLog

  constructor(log: QuecHttpLog) {
    super()
    this.log = log
  }

  public handler(response: AxiosResponse): AxiosResponse {
    try {
      this.log.response(response)
    } catch (error) {
      // Logging must not change the response outcome.
    }
    return response
  }

  public onError(error: Error): Promise<AxiosResponse> {
    try {
      this.log.error(error)
    } catch (loggingError) {
      // Preserve the original network error.
    }
    return super.onError(error)
  }
}
