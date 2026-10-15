import { HMServiceProvider } from '@hadss/hmrouter'
import { DEVICE_LIST_SERVICE, QuecDeviceListService } from '@quec/device-list-api'

import { deviceListBuilder } from '../builders/DeviceListBuilder'

@HMServiceProvider({ serviceName: DEVICE_LIST_SERVICE })
export class QuecDeviceListServiceImpl implements QuecDeviceListService {
  getDeviceListBuilder(): WrappedBuilder<[]> {
    return wrapBuilder(deviceListBuilder)
  }
}
