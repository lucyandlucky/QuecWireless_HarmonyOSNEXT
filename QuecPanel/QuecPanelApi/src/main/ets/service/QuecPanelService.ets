import { QuecPanelInfo } from '../model/QuecPanelInfo'

export const PANEL_SERVICE: string = 'quec.panel'

export interface QuecPanelService {
  loadPanel(info: QuecPanelInfo): void
}
