import { HMRouterMgr } from '@hadss/hmrouter'

import { PERSONAL_CENTER_SERVICE, QuecPersonalCenterService } from './QuecPersonalCenterService'

export class QuecPersonalCenterServiceManager {
  private static readonly instance: QuecPersonalCenterServiceManager = new QuecPersonalCenterServiceManager()

  private constructor() {
  }

  public static getInstance(): QuecPersonalCenterServiceManager {
    return QuecPersonalCenterServiceManager.instance
  }

  public getPersonalCenterBuilder(): WrappedBuilder<[]> | undefined {
    return HMRouterMgr.getService<QuecPersonalCenterService>(PERSONAL_CENTER_SERVICE)?.getPageBuilder()
  }
}
