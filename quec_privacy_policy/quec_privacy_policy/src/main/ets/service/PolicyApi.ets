import { QuecApiResponse, QuecNetworkV2 } from 'quec_network_v2';
import { PolicyType } from 'quec_privacy_policy_api';
import { PolicyTermDto } from '../model/PolicyTermDto';

const POLICY_APP_ID: string = '1'
const POLICY_PLATFORM: string = 'APP'

interface PolicyLatestParams {
  type: PolicyType
  appId: string
  platform: string
}

export interface PolicyDataSource {
  getLatest(type: PolicyType): Promise<PolicyTermDto>
}

export class PolicyApi implements PolicyDataSource {
  public async getLatest(type: PolicyType): Promise<PolicyTermDto> {
    const params: PolicyLatestParams = { type, appId: POLICY_APP_ID, platform: POLICY_PLATFORM }
    const response: QuecApiResponse<PolicyTermDto> = await QuecNetworkV2.getClient().get<PolicyTermDto>({
      url: '/v2/contentagreement/enduserapi/terms/latest',
      params
    })
    if (response.data === null || response.data === undefined) {
      throw new Error('Policy data is empty')
    }
    return response.data
  }
}
