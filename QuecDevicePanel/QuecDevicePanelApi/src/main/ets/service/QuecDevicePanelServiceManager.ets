import { HMRouterMgr } from '@hadss/hmrouter'

import { QuecDevicePanelInfo } from '../model/QuecDevicePanelInfo'
import { DEVICE_PANEL_SERVICE, QuecDevicePanelService } from './QuecDevicePanelService'

export class QuecDevicePanelServiceManager {
  private static readonly instance: QuecDevicePanelServiceManager = new QuecDevicePanelServiceManager()

  private constructor() {
  }

  public static getInstance(): QuecDevicePanelServiceManager {
    return QuecDevicePanelServiceManager.instance
  }

  public loadPanel(info: QuecDevicePanelInfo): void {
    HMRouterMgr.getService<QuecDevicePanelService>(DEVICE_PANEL_SERVICE)?.loadPanel(info)
  }
}
