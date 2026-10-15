export const PERSONAL_CENTER_SERVICE: string = 'quec.tab.personal_center'

export interface QuecPersonalCenterService {
  getPageBuilder(): WrappedBuilder<[]>
}
