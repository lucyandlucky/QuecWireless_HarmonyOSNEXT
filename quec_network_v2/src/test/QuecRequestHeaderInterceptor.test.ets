import { AxiosAdapter, AxiosHeaders, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { describe, expect, it } from '@ohos/hypium'
import { QuecNetworkV2 } from '../main/ets/core/QuecNetworkV2'

export default function quecRequestHeaderInterceptorTest(): void {
  describe('QuecRequestHeaderInterceptor', () => {
    it('adds internal defaults without replacing request headers', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = { data: 'ok', status: 200, statusText: 'OK', headers: {}, config }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })
      const headers: AxiosHeaders = new AxiosHeaders()
      headers.set('X-Q-language', 'en_US')
      headers.set('X-App', 'wireless')

      await QuecNetworkV2.getClient().get<string>({ url: '/items', headers })
      const sent: AxiosHeaders = (captured as InternalAxiosRequestConfig).headers
      expect(sent.get('X-Q-language')).assertEqual('en_US')
      expect(sent.get('X-App')).assertEqual('wireless')
      expect(sent.getContentType()).assertEqual('application/json')

      await QuecNetworkV2.getClient().get<string>({ url: '/items' })
      expect((captured as InternalAxiosRequestConfig).headers.get('X-Q-language')).assertEqual('zh_CN')
    })
  })
}
