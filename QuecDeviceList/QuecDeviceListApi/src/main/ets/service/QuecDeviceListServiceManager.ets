import { HMRouterMgr } from '@hadss/hmrouter'

import { DEVICE_LIST_SERVICE, QuecDeviceListService } from './QuecDeviceListService'

export class QuecDeviceListServiceManager {
  private static readonly instance: QuecDeviceListServiceManager = new QuecDeviceListServiceManager()

  private constructor() {
  }

  public static getInstance(): QuecDeviceListServiceManager {
    return QuecDeviceListServiceManager.instance
  }

  public getDeviceListBuilder(): WrappedBuilder<[]> | undefined {
    return HMRouterMgr.getService<QuecDeviceListService>(DEVICE_LIST_SERVICE)?.getDeviceListBuilder()
  }
}
