import { QuecApiResponse, QuecFormBody, QuecNetworkV2 } from 'quec_network_v2'
import { QuecLoginTokenData, QuecUserModel } from '../model/QuecUserModel'

export interface QuecUserDataSource {
  loginByEmail(formBody: QuecFormBody): Promise<QuecApiResponse<QuecLoginTokenData>>

  loginByPhone(formBody: QuecFormBody): Promise<QuecApiResponse<QuecLoginTokenData>>

  getUserInfo(): Promise<QuecApiResponse<QuecUserModel>>

  logout(): Promise<QuecApiResponse<void>>
}

export class QuecUserApi implements QuecUserDataSource {
  public loginByEmail(formBody: QuecFormBody): Promise<QuecApiResponse<QuecLoginTokenData>> {
    return QuecNetworkV2.getClient().post<QuecLoginTokenData>({
      url: '/v2/enduser/enduserapi/emailPwdLogin', formBody
    })
  }

  public loginByPhone(formBody: QuecFormBody): Promise<QuecApiResponse<QuecLoginTokenData>> {
    return QuecNetworkV2.getClient().post<QuecLoginTokenData>({
      url: '/v2/enduser/enduserapi/phonePwdLogin', formBody
    })
  }

  public getUserInfo(): Promise<QuecApiResponse<QuecUserModel>> {
    return QuecNetworkV2.getClient().get<QuecUserModel>({
      url: '/v2/enduser/enduserapi/userInfo'
    })
  }

  public logout(): Promise<QuecApiResponse<void>> {
    return QuecNetworkV2.getClient().delete<void>({
      url: '/v2/enduser/enduserapi/userLogout'
    })
  }
}
