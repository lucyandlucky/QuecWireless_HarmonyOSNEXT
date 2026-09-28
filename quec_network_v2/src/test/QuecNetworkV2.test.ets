import {
  AxiosAdapter,
  AxiosHeaders,
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  InternalAxiosRequestConfig
} from '@ohos/axios'
import { describe, expect, it } from '@ohos/hypium'
import { QuecNetworkV2 } from '../main/ets/core/QuecNetworkV2'

export default function quecNetworkV2Test(): void {
  describe('QuecNetworkV2', () => {
    it('creates an isolated axios instance with native interceptors', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = {
          data: '{"ok":true}',
          status: 200,
          statusText: 'OK',
          headers: {},
          config
        }
        return Promise.resolve(response)
      }
      const client: AxiosInstance = QuecNetworkV2.createClient({
        baseURL: 'https://example.com/api',
        timeout: 1000,
        adapter
      })
      const otherClient: AxiosInstance = QuecNetworkV2.createClient({
        baseURL: 'https://other.example.com',
        timeout: 2500
      })
      const order: string[] = []
      client.interceptors.request.use((config: InternalAxiosRequestConfig) => {
        order.push('request')
        config.headers.set('X-App', 'wireless')
        return config
      })
      client.interceptors.response.use((response: AxiosResponse) => {
        order.push('response')
        return response
      })

      const params: Record<string, number> = {}
      params.page = 2
      const response: AxiosResponse<Record<string, boolean>> = await client.get<Record<string, boolean>>(
        '/items', { params }
      )
      const sent: InternalAxiosRequestConfig = captured as InternalAxiosRequestConfig
      expect(order.join(',')).assertEqual('request,response')
      expect(sent.baseURL).assertEqual('https://example.com/api')
      expect(sent.url).assertEqual('/items')
      expect(sent.timeout).assertEqual(1000)
      expect(client.defaults.timeout).assertEqual(1000)
      expect(otherClient.defaults.timeout).assertEqual(2500)
      expect(sent.headers.get('X-App')).assertEqual('wireless')
      expect(response.data.ok).assertTrue()
    })

    it('selects form encoding explicitly', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      let inputEmail: string = ''
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = {
          data: 'ok', status: 200, statusText: 'OK', headers: {}, config
        }
        return Promise.resolve(response)
      }
      const client: AxiosInstance = QuecNetworkV2.createClient({ baseURL: 'https://example.com', adapter })
      const headers: AxiosHeaders = new AxiosHeaders()
      headers.setContentType('application/x-www-form-urlencoded')
      const body: Record<string, string> = {}
      body.email = 'a@b.com'
      body.pwd = 'x y'
      const options: AxiosRequestConfig<Record<string, string>> = { headers }
      const interceptorId: number = client.interceptors.request.use((config: InternalAxiosRequestConfig) => {
        inputEmail = (config.data as Record<string, string>).email
        return config
      })

      await client.post<string, AxiosResponse<string>, Record<string, string>>('/login', body, options)
      expect(inputEmail).assertEqual('a@b.com')
      expect(typeof (captured as InternalAxiosRequestConfig).data).assertEqual('string')
      expect((captured as InternalAxiosRequestConfig).headers.getContentType())
        .assertEqual('application/x-www-form-urlencoded')

      client.interceptors.request.eject(interceptorId)
      const encodedOptions: AxiosRequestConfig<string> = { headers }
      await client.post<string, AxiosResponse<string>, string>(
        '/login', 'email=a%40b.com&pwd=x%20y', encodedOptions
      )
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
      const client: AxiosInstance = QuecNetworkV2.createClient({ baseURL: 'https://example.com', adapter })
      const response: AxiosResponse<string> = await client.post<string, AxiosResponse<string>, string>(
        '/raw', 'already encoded', { responseType: 'string' }
      )
      expect((captured as InternalAxiosRequestConfig).data as string).assertEqual('already encoded')
      expect(response.data).assertEqual('plain text')
    })
  })
}
