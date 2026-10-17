import { HMRouterMgr, HMServiceProvider } from '@hadss/hmrouter'
import { PANEL_SERVICE, QuecPanelInfo, QuecPanelService } from '@quec/panel-api'
import { RN_PAGE_ROUTE } from '../navigation/QuecPanelRoutes'

@HMServiceProvider({ serviceName: PANEL_SERVICE })
export class QuecPanelServiceImpl implements QuecPanelService {
  public loadPanel(info: QuecPanelInfo): void {
    HMRouterMgr.push({ pageUrl: RN_PAGE_ROUTE, param: info })
  }
}
