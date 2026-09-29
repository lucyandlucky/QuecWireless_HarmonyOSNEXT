import { describe, expect, it } from '@ohos/hypium'
import { AxiosAdapter, AxiosResponse, InternalAxiosRequestConfig, QuecNetworkV2 } from 'quec_network_v2'
import { PolicyType } from 'quec_privacy_policy_api'
import { PolicyTermDto } from '../main/ets/model/PolicyTermDto'
import { PolicyApi } from '../main/ets/service/PolicyApi'

export default function policyApiTest(): void {
  describe('PolicyApi', () => {
    it('requests the latest term and returns unwrapped data', 0, async () => {
      let captured: InternalAxiosRequestConfig | undefined
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured = config
        const response: AxiosResponse<string> = {
          data: '{"code":200,"data":{"htmlCnFileUrl":"https://example.com/policy.html"}}',
          status: 200,
          statusText: 'OK',
          headers: {},
          config
        }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })

      const term: PolicyTermDto = await new PolicyApi().getLatest(PolicyType.PRIVACY)
      const request: InternalAxiosRequestConfig = captured as InternalAxiosRequestConfig
      const params: Record<string, string> = request.params as Record<string, string>
      expect(request.baseURL).assertEqual('https://example.com')
      expect(request.url).assertEqual('/v2/contentagreement/enduserapi/terms/latest')
      expect(request.method).assertEqual('get')
      expect(params.type).assertEqual(PolicyType.PRIVACY)
      expect(params.appId).assertEqual('1')
      expect(params.platform).assertEqual('APP')
      expect(term.htmlCnFileUrl).assertEqual('https://example.com/policy.html')
    })

    it('rejects an empty policy payload', 0, async () => {
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        const response: AxiosResponse<string> = {
          data: '{"code":200,"data":null}',
          status: 200,
          statusText: 'OK',
          headers: {},
          config
        }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })

      let message: string = ''
      try {
        await new PolicyApi().getLatest(PolicyType.SERVICE)
      } catch (error) {
        message = (error as Error).message
      }
      expect(message).assertEqual('Policy data is empty')
    })
  })
}
