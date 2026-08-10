import { QuecNetwork, QuecQueryParams, QuecRequestOptions } from 'quec_network';
import { PolicyType } from 'quec_privacy_policy_api';
import { PolicyTermDto } from '../model/PolicyTermDto';

const POLICY_APP_ID: string = '1'
const POLICY_PLATFORM: string = 'APP'

export interface PolicyDataSource {
  getLatest(type: PolicyType): Promise<PolicyTermDto>
}

export class PolicyApi implements PolicyDataSource {
  public async getLatest(type: PolicyType): Promise<PolicyTermDto> {
    const queryParams: QuecQueryParams = {}
    queryParams.type = type
    queryParams.appId = POLICY_APP_ID
    queryParams.platform = POLICY_PLATFORM

    const options: QuecRequestOptions = { queryParams }

    return QuecNetwork.getClient().get(
      '/v2/contentagreement/enduserapi/terms/latest',
      options
    )
  }
}
