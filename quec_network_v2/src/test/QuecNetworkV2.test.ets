import {
  AxiosAdapter,
  AxiosHeaders,
  AxiosResponse,
  InternalAxiosRequestConfig
} from '@ohos/axios'
import { describe, expect, it } from '@ohos/hypium'
import { QuecNetworkV2 } from '../main/ets/core/QuecNetworkV2'
import { QuecApiResponse } from '../main/ets/model/QuecApiResponse'

export default function quecNetworkV2Test(): void {
  describe('QuecNetworkV2', () => {
    it('uses initialization defaults and request overrides', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = {
          data: '{"code":200,"msg":"","data":{"ok":true}}',
          status: 200,
          statusText: 'OK',
          headers: {},
          config
        }
        return Promise.resolve(response)
      }
      const defaultHeaders: AxiosHeaders = new AxiosHeaders()
      defaultHeaders.set('appVersion', '1.2.3')
      defaultHeaders.set('appSystemType', 'harmony')
      defaultHeaders.set('X-Q-language', 'en_US')
      QuecNetworkV2.init({
        baseURL: 'https://example.com/api',
        timeout: 1000,
        headers: defaultHeaders,
        adapter
      })
      const params: Record<string, number> = {}
      params.page = 2
      const response: QuecApiResponse<Record<string, boolean>> = await QuecNetworkV2.getClient()
        .get<Record<string, boolean>>({ url: '/items', params })
      const sent: InternalAxiosRequestConfig = captured as InternalAxiosRequestConfig
      expect(sent.baseURL).assertEqual('https://example.com/api')
      expect(sent.url).assertEqual('/items')
      expect(sent.timeout).assertEqual(1000)
      expect(sent.headers.get('appVersion')).assertEqual('1.2.3')
      expect(sent.headers.get('appSystemType')).assertEqual('harmony')
      expect(sent.headers.get('X-Q-language')).assertEqual('en_US')
      expect(response.code).assertEqual(200)
      expect(response.msg).assertEqual('')
      expect((response.data as Record<string, boolean>).ok).assertTrue()

      const headers: AxiosHeaders = new AxiosHeaders()
      headers.set('appVersion', '2.0.0')
      headers.set('X-App', 'wireless')
      await QuecNetworkV2.getClient().get({ url: '/items', timeout: 2500, headers })
      expect((captured as InternalAxiosRequestConfig).timeout).assertEqual(2500)
      expect((captured as InternalAxiosRequestConfig).headers.get('appVersion')).assertEqual('2.0.0')
      expect((captured as InternalAxiosRequestConfig).headers.get('appSystemType')).assertEqual('harmony')
      expect((captured as InternalAxiosRequestConfig).headers.get('X-App')).assertEqual('wireless')
    })

    it('selects form encoding explicitly', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = {
          data: '{"code":200,"msg":"","data":null}', status: 200, statusText: 'OK', headers: {}, config
        }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })
      const headers: AxiosHeaders = new AxiosHeaders()
      headers.setContentType('application/x-www-form-urlencoded')
      const body: Record<string, string> = {}
      body.email = 'a@b.com'
      body.pwd = 'x y'

      await QuecNetworkV2.getClient().post({ url: '/login', body, headers })
      expect(typeof (captured as InternalAxiosRequestConfig).data).assertEqual('string')
      expect((captured as InternalAxiosRequestConfig).headers.getContentType())
        .assertEqual('application/x-www-form-urlencoded')

      await QuecNetworkV2.getClient().post({ url: '/login', body: 'email=a%40b.com&pwd=x%20y', headers })
      expect((captured as InternalAxiosRequestConfig).data as string).assertEqual('email=a%40b.com&pwd=x%20y')
    })

    it('preserves raw data and string responses', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = {
          data: 'plain text', status: 200, statusText: 'OK', headers: {}, config
        }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })
      const headers: AxiosHeaders = new AxiosHeaders()
      headers.setContentType('text/plain')
      const response: AxiosResponse<string> = await QuecNetworkV2.getClient().requestRaw<string>({
        method: 'POST', url: '/raw', body: 'already encoded', headers
      })
      expect((captured as InternalAxiosRequestConfig).data as string).assertEqual('already encoded')
      expect((captured as InternalAxiosRequestConfig).headers.getContentType()).assertEqual('text/plain')
      expect(response.data).assertEqual('plain text')
    })
  })
}
