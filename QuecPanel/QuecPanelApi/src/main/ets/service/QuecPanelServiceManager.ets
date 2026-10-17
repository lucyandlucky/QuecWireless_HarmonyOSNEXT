import { HMRouterMgr } from '@hadss/hmrouter'

import { QuecPanelInfo } from '../model/QuecPanelInfo'
import { PANEL_SERVICE, QuecPanelService } from './QuecPanelService'

export class QuecPanelServiceManager {
  private static readonly instance: QuecPanelServiceManager = new QuecPanelServiceManager()

  private constructor() {
  }

  public static getInstance(): QuecPanelServiceManager {
    return QuecPanelServiceManager.instance
  }

  public loadPanel(info: QuecPanelInfo): void {
    HMRouterMgr.getService<QuecPanelService>(PANEL_SERVICE)?.loadPanel(info)
  }
}
