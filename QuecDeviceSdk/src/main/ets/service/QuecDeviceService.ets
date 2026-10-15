import { QuecPaaSListResponse } from '@quec/network-v2'
import { QuecDeviceListParamsModel } from '../model/QuecDeviceListParamsModel'
import { QuecDeviceModel } from '../model/QuecDeviceModel'
import { QuecDeviceApi } from './QuecDeviceApi'

export class QuecDeviceService {
  private static readonly api: QuecDeviceApi = new QuecDeviceApi()

  public static async getDeviceList(
    params: QuecDeviceListParamsModel = new QuecDeviceListParamsModel()
  ): Promise<QuecPaaSListResponse<QuecDeviceModel>> {
    const response = await QuecDeviceService.api.getDeviceList(params)

    for (const device of response.data.list) {
      // 未提供能力位时按默认能力位处理
      if ((device.capabilitiesBitmask ?? 0) === 0) {
        device.capabilitiesBitmask = 1
      }
      device.isShared = device.shareCode !== undefined && device.shareCode !== null && device.shareCode.length > 0
    }
    return response
  }
}
