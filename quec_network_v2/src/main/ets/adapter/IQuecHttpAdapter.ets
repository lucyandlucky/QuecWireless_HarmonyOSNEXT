import { QuecRequestConfig } from '../model/QuecRequestConfig'
import { QuecRawResponse } from '../model/QuecResponse'

export interface IQuecHttpAdapter {
  // QuecHttpClient resolves relative paths before calling the adapter.
  execute(config: QuecRequestConfig): Promise<QuecRawResponse>
}
