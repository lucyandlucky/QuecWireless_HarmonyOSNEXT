import { AxiosAdapter, AxiosHeaders, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { describe, expect, it } from '@ohos/hypium'
import { QuecApiResponse, QuecNetwork } from '../../Index'
import { QuecNetworkV2 } from '../main/ets/core/QuecNetworkV2'

interface ItemResponse {
  id: number
}

interface ItemParams {
  page: number
}

interface ItemFilter {
  status: string
}

export default function quecNetworkV2RequestTest(): void {
  describe('QuecNetworkV2 requests', () => {
    it('requires initialization before getting the shared client', 0, () => {
      let errorMessage: string = ''
      try {
        QuecNetworkV2.getClient()
      } catch (error) {
        errorMessage = (error as Error).message
      }
      expect(errorMessage).assertEqual('Call QuecNetworkV2.init before getting the network client')
    })

    it('reuses one client after initialization', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = {
          data: '{"code":200,"msg":"","data":null}', status: 200, statusText: 'OK', headers: {}, config
        }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })
      const sharedClient: QuecNetworkV2 = QuecNetworkV2.getClient()

      const result: QuecApiResponse<Object> = await QuecNetwork.getClient().get({ url: '/items' })
      expect(result.code).assertEqual(200)
      expect(QuecNetworkV2.getClient() === sharedClient).assertTrue()
      expect((captured as InternalAxiosRequestConfig).baseURL).assertEqual('https://example.com')
      expect((captured as InternalAxiosRequestConfig).headers.get('X-Q-language')).assertEqual('zh_CN')

      QuecNetworkV2.init({ baseURL: 'https://other.example.com', adapter })
      await sharedClient.get({ url: '/items' })
      expect(QuecNetworkV2.getClient() === sharedClient).assertTrue()
      expect((captured as InternalAxiosRequestConfig).baseURL).assertEqual('https://other.example.com')
    })

    it('maps GET params and body to Axios without losing default headers', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = {
          data: '{"code":200,"msg":"","data":{"id":7}}', status: 200, statusText: 'OK', headers: {}, config
        }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })
      const params: ItemParams = { page: 2 }
      const body: ItemFilter = { status: 'active' }
      const response: QuecApiResponse<ItemResponse> = await QuecNetworkV2.getClient().get<ItemResponse>({
        url: '/items', params, body
      })

      expect(response.code).assertEqual(200)
      expect((response.data as ItemResponse).id).assertEqual(7)
      expect((captured as InternalAxiosRequestConfig).method).assertEqual('get')
      expect((captured as InternalAxiosRequestConfig).url).assertEqual('/items')
      expect(((captured as InternalAxiosRequestConfig).params as Record<string, number>).page).assertEqual(2)
      expect((captured as InternalAxiosRequestConfig).data as string).assertEqual('{"status":"active"}')
      expect((captured as InternalAxiosRequestConfig).headers.get('X-Q-language')).assertEqual('zh_CN')

      await QuecNetworkV2.getClient().get({ url: '/items', params: {}, body: {} })
    })

    it('maps write methods and respects request-specific headers', 0, async () => {
      const methods: string[] = []
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        methods.push(config.method ?? '')
        const response: AxiosResponse<string> = {
          data: '{"code":200,"msg":"","data":null}', status: 200, statusText: 'OK', headers: {}, config
        }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })
      const headers: AxiosHeaders = new AxiosHeaders()
      headers.setContentType('text/plain')

      await QuecNetworkV2.getClient().post({ url: '/items', body: 'raw', headers })
      expect((captured as InternalAxiosRequestConfig).data as string).assertEqual('raw')
      expect((captured as InternalAxiosRequestConfig).headers.getContentType()).assertEqual('text/plain')
      await QuecNetworkV2.getClient().put({ url: '/items', body: {} })
      await QuecNetworkV2.getClient().delete({ url: '/items', body: {} })
      expect(methods.join(',')).assertEqual('post,put,delete')
    })
  })
}
