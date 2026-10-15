import { QuecUserCenterId } from '@quec/oem-app-config'

const MENU_TITLES: Map<string, Resource> = new Map<string, Resource>()
MENU_TITLES.set('quec_custom_usercenter_device', $r('app.string.quec_custom_usercenter_device'))
MENU_TITLES.set('quec_custom_usercenter_message', $r('app.string.quec_custom_usercenter_message'))
MENU_TITLES.set('quec_custom_key_setting', $r('app.string.quec_custom_key_setting'))
MENU_TITLES.set('quec_custom_user_aboutme', $r('app.string.quec_custom_user_aboutme'))
MENU_TITLES.set('quec_custom_user_help', $r('app.string.quec_custom_user_help'))
MENU_TITLES.set('quec_custom_user_issue', $r('app.string.quec_custom_user_issue'))

const MENU_ICONS: Map<string, Resource> = new Map<string, Resource>()
MENU_ICONS.set(QuecUserCenterId.DEVICE, $r('app.media.quec_personal_center_ic_device_manager'))
MENU_ICONS.set(QuecUserCenterId.MESSAGE, $r('app.media.quec_personal_center_ic_message_center'))
MENU_ICONS.set(QuecUserCenterId.SETTING, $r('app.media.quec_personal_center_ic_setting'))
MENU_ICONS.set(QuecUserCenterId.ABOUT, $r('app.media.quec_personal_center_ic_about'))
MENU_ICONS.set(QuecUserCenterId.HELP, $r('app.media.quec_personal_center_ic_help_doc'))
MENU_ICONS.set(QuecUserCenterId.FEEDBACK, $r('app.media.quec_personal_center_ic_feedback'))

export class QuecPersonalCenterResources {
  public static title(key: string): ResourceStr {
    return MENU_TITLES.get(key) ?? key
  }

  public static icon(identifier: string): Resource | undefined {
    return MENU_ICONS.get(identifier)
  }
}
