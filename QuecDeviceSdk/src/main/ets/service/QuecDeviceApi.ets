import { QuecApiUrl, QuecNetworkV2, QuecPaaSListResponse } from '@quec/network-v2'
import { QuecDeviceListParamsModel } from '../model/QuecDeviceListParamsModel'
import { QuecDeviceModel } from '../model/QuecDeviceModel'

export class QuecDeviceApi {
  public getDeviceList(params: QuecDeviceListParamsModel): Promise<QuecPaaSListResponse<QuecDeviceModel>> {
    return QuecNetworkV2.getClient().get<QuecPaaSListResponse<QuecDeviceModel>>({
      url: QuecApiUrl.paas('/v2/binding/enduserapi/userDeviceList'),
      params: params
    })
  }
}
