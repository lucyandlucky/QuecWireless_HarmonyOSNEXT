import { AxiosResponse } from '@ohos/axios'

export interface IQuecResponseInterceptor {
  handler(response: AxiosResponse): AxiosResponse | Promise<AxiosResponse>
  onError(error: Error): Promise<AxiosResponse>
}

export abstract class QuecResponseInterceptor implements IQuecResponseInterceptor {
  public abstract handler(response: AxiosResponse): AxiosResponse | Promise<AxiosResponse>

  public onError(error: Error): Promise<AxiosResponse> {
    return Promise.reject(error)
  }
}
