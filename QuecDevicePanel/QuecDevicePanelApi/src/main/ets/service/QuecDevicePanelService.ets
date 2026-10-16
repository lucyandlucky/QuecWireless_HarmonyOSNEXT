import { QuecDevicePanelInfo } from '../model/QuecDevicePanelInfo'

export const DEVICE_PANEL_SERVICE: string = 'quec.device.panel'

export interface QuecDevicePanelService {
  loadPanel(info: QuecDevicePanelInfo): void
}
