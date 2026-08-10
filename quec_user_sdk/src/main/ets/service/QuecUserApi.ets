import { QuecFormBody, QuecNetwork } from 'quec_network';
import { QuecLoginTokenData, QuecUserModel } from '../model/QuecUserModel';

export interface QuecUserDataSource {
  loginByEmail(formBody: QuecFormBody): Promise<QuecLoginTokenData>

  loginByPhone(formBody: QuecFormBody): Promise<QuecLoginTokenData>

  getUserInfo(): Promise<QuecUserModel>
}

export class QuecUserApi implements QuecUserDataSource {
  getUserInfo(): Promise<QuecUserModel> {
    return QuecNetwork
      .getClient()
      .get(
        '/v2/enduser/enduserapi/userInfo'
      )
  }

  public loginByEmail(formBody: QuecFormBody): Promise<QuecLoginTokenData> {
    return QuecNetwork.getClient().post<QuecLoginTokenData>(
      '/v2/enduser/enduserapi/emailPwdLogin',
      undefined,
      { formBody: formBody }
    )
  }

  public loginByPhone(formBody: QuecFormBody): Promise<QuecLoginTokenData> {
    return QuecNetwork.getClient().post<QuecLoginTokenData>(
      '/v2/enduser/enduserapi/phonePwdLogin',
      undefined,
      { formBody: formBody }
    )
  }
}