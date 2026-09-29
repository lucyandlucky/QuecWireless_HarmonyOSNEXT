import {
  AxiosAdapter,
  AxiosResponse,
  InternalAxiosRequestConfig,
  QuecApiResponse,
  QuecFormBody,
  QuecNetworkV2
} from 'quec_network_v2'
import { describe, expect, it } from '@ohos/hypium'
import { QuecUserApi } from '../main/ets/service/QuecUserApi'
import { QuecLoginTokenData, QuecUserModel } from '../main/ets/model/QuecUserModel'

function createAdapter(payload: string, captured: InternalAxiosRequestConfig[]): AxiosAdapter {
  return (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
    captured.push(config)
    const response: AxiosResponse<string> = { data: payload, status: 200, statusText: 'OK', headers: {}, config }
    return Promise.resolve(response)
  }
}

export default function quecUserApiTest(): void {
  describe('QuecUserApi', () => {
    it('sends email and phone login with form content type', 0, async () => {
      const captured: InternalAxiosRequestConfig[] = []
      const payload: string = '{"code":200,"data":{"accessToken":{"token":"access","expirationTime":1},' +
        '"refreshToken":{"token":"refresh","expirationTime":2}}}'
      QuecNetworkV2.init({
        baseURL: 'https://example.com',
        adapter: createAdapter(payload, captured),
        transformRequest: [(data: Object): Object => data]
      })
      const api: QuecUserApi = new QuecUserApi()
      const emailForm: QuecFormBody = {}
      emailForm['email'] = 'a+b@example.com'
      emailForm['pwd'] = 'x y'
      emailForm['random'] = 'r'
      emailForm['userDomain'] = 'domain'
      emailForm['signature'] = 's'
      const emailResponse: QuecApiResponse<QuecLoginTokenData> = await api.loginByEmail(emailForm)
      expect((emailResponse.data as QuecLoginTokenData).accessToken.token).assertEqual('access')
      expect(captured[0].url).assertEqual('/v2/enduser/enduserapi/emailPwdLogin')
      expect((captured[0].data as QuecFormBody)['email']).assertEqual('a+b@example.com')
      expect((captured[0].data as QuecFormBody)['pwd']).assertEqual('x y')
      expect(captured[0].headers.getContentType()).assertEqual('application/x-www-form-urlencoded')

      const phoneForm: QuecFormBody = {}
      phoneForm['internationalCode'] = '86'
      phoneForm['phone'] = '123456'
      phoneForm['pwd'] = 'x y'
      phoneForm['random'] = 'r'
      phoneForm['userDomain'] = 'domain'
      phoneForm['signature'] = 's'
      await api.loginByPhone(phoneForm)
      expect(captured[1].url).assertEqual('/v2/enduser/enduserapi/phonePwdLogin')
      expect((captured[1].data as QuecFormBody)['internationalCode']).assertEqual('86')
      expect((captured[1].data as QuecFormBody)['phone']).assertEqual('123456')
      expect(captured[1].headers.getContentType()).assertEqual('application/x-www-form-urlencoded')
    })

    it('fetches user info and logs out through V2', 0, async () => {
      const captured: InternalAxiosRequestConfig[] = []
      const adapter: AxiosAdapter = (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
        captured.push(config)
        const payload: string = config.method === 'delete' ? '{"code":200,"data":null}' :
          '{"code":200,"data":{"uid":"user-1"}}'
        const response: AxiosResponse<string> = { data: payload, status: 200, statusText: 'OK', headers: {}, config }
        return Promise.resolve(response)
      }
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter })
      const api: QuecUserApi = new QuecUserApi()

      const userResponse: QuecApiResponse<QuecUserModel> = await api.getUserInfo()
      expect((userResponse.data as QuecUserModel).uid).assertEqual('user-1')
      expect(captured[0].url).assertEqual('/v2/enduser/enduserapi/userInfo')

      await api.logout()
      expect(captured[1].url).assertEqual('/v2/enduser/enduserapi/userLogout')
    })

    it('returns the envelope when login data is missing', 0, async () => {
      QuecNetworkV2.init({ baseURL: 'https://example.com', adapter: createAdapter('{"code":200,"data":null}', []) })
      const api: QuecUserApi = new QuecUserApi()
      const formBody: QuecFormBody = {}
      formBody['email'] = 'user@example.com'
      const response: QuecApiResponse<QuecLoginTokenData> = await api.loginByEmail(formBody)
      expect(response.data === null).assertTrue()
    })
  })
}
