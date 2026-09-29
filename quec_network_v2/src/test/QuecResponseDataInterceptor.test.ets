import { AxiosAdapter, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { describe, expect, it } from '@ohos/hypium'
import { QuecApiResponse, QuecBusinessError, QuecNetworkV2 } from '../../Index'

interface ItemResponse {
  id: number
}

function createAdapter(data: string): AxiosAdapter {
  return (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
    const response: AxiosResponse<string> = { data, status: 200, statusText: 'OK', headers: {}, config }
    return Promise.resolve(response)
  }
}

export default function quecResponseDataInterceptorTest(): void {
  describe('QuecResponseDataInterceptor', () => {
    it('returns the complete successful business response', 0, async () => {
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter: createAdapter('{"code":200,"msg":"","data":{"id":7}}') })

      const response: QuecApiResponse<ItemResponse> = await QuecNetworkV2.getClient().get<ItemResponse>({ url: '/items' })
      expect(response.code).assertEqual(200)
      expect(response.msg).assertEqual('')
      expect((response.data as ItemResponse).id).assertEqual(7)
    })

    it('rejects a business error with code and subCode', 0, async () => {
      QuecNetworkV2.init({
        baseURL: 'https://example.com',
        adapter: createAdapter('{"code":5032,"msg":"token invalid","subCode":1001}')
      })

      let caught: Error | undefined
      try {
        await QuecNetworkV2.getClient().get({ url: '/items' })
      } catch (error) {
        caught = error as Error
      }
      expect(caught instanceof QuecBusinessError).assertTrue()
      const businessError: QuecBusinessError = caught as QuecBusinessError
      expect(businessError.code).assertEqual(5032)
      expect(businessError.subCode).assertEqual(1001)
      expect(businessError.message).assertEqual('token invalid')
    })

    it('preserves non-business responses through requestRaw', 0, async () => {
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter: createAdapter('{"id":5}') })
      const objectResponse: AxiosResponse<ItemResponse> = await QuecNetworkV2.getClient()
        .requestRaw<ItemResponse>({ method: 'GET', url: '/items' })
      expect(objectResponse.data.id).assertEqual(5)

      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter: createAdapter('plain text') })
      const textResponse: AxiosResponse<string> = await QuecNetworkV2.getClient()
        .requestRaw<string>({ method: 'GET', url: '/raw' })
      expect(textResponse.data).assertEqual('plain text')
    })

    it('bypasses business errors for requestRaw', 0, async () => {
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter: createAdapter('{"code":5032,"msg":"expired"}') })

      const response: AxiosResponse<QuecApiResponse<Object>> = await QuecNetworkV2.getClient()
        .requestRaw<QuecApiResponse<Object>>({ method: 'GET', url: '/raw' })
      expect(response.status).assertEqual(200)
      expect(response.data.code).assertEqual(5032)
    })

    it('keeps null data for successful responses', 0, async () => {
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter: createAdapter('{"code":200,"data":null}') })

      const response: QuecApiResponse<Object | null> = await QuecNetworkV2.getClient()
        .get<Object | null>({ url: '/empty' })
      expect(response.data === null).assertTrue()
    })

    it('rejects non-business responses on standard requests', 0, async () => {
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter: createAdapter('plain text') })

      let message: string = ''
      try {
        await QuecNetworkV2.getClient().get({ url: '/raw' })
      } catch (error) {
        message = (error as Error).message
      }
      expect(message).assertEqual('Response is not a Quec API response')
    })

    it('rejects an envelope with an invalid code', 0, async () => {
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter: createAdapter('{"code":"200"}') })

      let message: string = ''
      try {
        await QuecNetworkV2.getClient().get({ url: '/items' })
      } catch (error) {
        message = (error as Error).message
      }
      expect(message).assertEqual('Response code is missing or invalid')
    })
  })
}
