import { QuecApiUrl, QuecFormBody, QuecNetworkV2, QuecPaaSResponse } from '@quec/network-v2'
import { QuecLoginTokenData, QuecUserModel } from '../model/QuecUserModel'

export interface QuecUserDataSource {
  loginByEmail(formBody: QuecFormBody): Promise<QuecPaaSResponse<QuecLoginTokenData>>

  loginByPhone(formBody: QuecFormBody): Promise<QuecPaaSResponse<QuecLoginTokenData>>

  getUserInfo(): Promise<QuecPaaSResponse<QuecUserModel>>

  logout(): Promise<QuecPaaSResponse<void>>
}

export class QuecUserApi implements QuecUserDataSource {
  public loginByEmail(formBody: QuecFormBody): Promise<QuecPaaSResponse<QuecLoginTokenData>> {
    return QuecNetworkV2.getClient().post<QuecPaaSResponse<QuecLoginTokenData>>({
      url: QuecApiUrl.paas('/v2/enduser/enduserapi/emailPwdLogin'), formBody
    })
  }

  public loginByPhone(formBody: QuecFormBody): Promise<QuecPaaSResponse<QuecLoginTokenData>> {
    return QuecNetworkV2.getClient().post<QuecPaaSResponse<QuecLoginTokenData>>({
      url: QuecApiUrl.paas('/v2/enduser/enduserapi/phonePwdLogin'), formBody
    })
  }

  public getUserInfo(): Promise<QuecPaaSResponse<QuecUserModel>> {
    return QuecNetworkV2.getClient().get<QuecPaaSResponse<QuecUserModel>>({
      url: QuecApiUrl.paas('/v2/enduser/enduserapi/userInfo')
    })
  }

  public logout(): Promise<QuecPaaSResponse<void>> {
    return QuecNetworkV2.getClient().delete<QuecPaaSResponse<void>>({
      url: QuecApiUrl.paas('/v2/enduser/enduserapi/userLogout')
    })
  }
}
