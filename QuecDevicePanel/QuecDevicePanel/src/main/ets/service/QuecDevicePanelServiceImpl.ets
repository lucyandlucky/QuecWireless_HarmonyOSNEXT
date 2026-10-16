import { HMRouterMgr, HMServiceProvider } from '@hadss/hmrouter'
import { DEVICE_PANEL_SERVICE, QuecDevicePanelInfo, QuecDevicePanelService } from '@quec/device-panel-api'

import { DEVICE_PANEL_ROUTE } from '../navigation/QuecDevicePanelRoutes'

@HMServiceProvider({ serviceName: DEVICE_PANEL_SERVICE })
export class QuecDevicePanelServiceImpl implements QuecDevicePanelService {
  public loadPanel(info: QuecDevicePanelInfo): void {
    HMRouterMgr.push({ pageUrl: DEVICE_PANEL_ROUTE, param: info })
  }
}
