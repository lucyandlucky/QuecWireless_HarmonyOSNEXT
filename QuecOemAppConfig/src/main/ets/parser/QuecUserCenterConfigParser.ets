import { QLog } from '@quec/log'

import { QuecUserCenterId } from '../constants/userCenter'
import { QuecOemBasicConfigModel } from '../model/QuecOemBasicConfigModel'
import { QuecOemBusinessConfigModel } from '../model/QuecOemBusinessConfigModel'
import {
  QuecUserCenterConfigModel,
  QuecUserCenterMainModel,
  QuecUserCenterSubModel,
  QuecUserCenterSubParamsModel
} from '../model/QuecUserCenterConfigModel'
import { QuecOemRawReader as R, QuecRawObject, QuecRawValue } from './QuecOemRawReader'

const ENERGY_APP_TYPE: number = 1166110884101666

export class QuecUserCenterConfigParser {
  public static parse(business: QuecOemBusinessConfigModel,
    basic: QuecOemBasicConfigModel): QuecUserCenterConfigModel {
    const config: QuecUserCenterConfigModel = new QuecUserCenterConfigModel()
    if (business.userCenterConfig.trim().length === 0) {
      return config
    }
    try {
      let entries: QuecRawValue = JSON.parse(business.userCenterConfig) as QuecRawValue
      if (typeof entries === 'string') {
        entries = JSON.parse(entries) as QuecRawValue
      }
      if (!Array.isArray(entries)) {
        QLog.w('QuecUserCenterConfigParser', 'userCenterConfig must be an array')
        return config
      }
      for (const entry of entries as QuecRawValue[]) {
        const raw: QuecRawObject | undefined = R.asObject(entry)
        if (raw === undefined) {
          continue
        }
        const group: QuecUserCenterMainModel = QuecUserCenterConfigParser.group(raw)
        if (group.identifier === QuecUserCenterId.HEADER) {
          config.header = group
        } else if (group.identifier === QuecUserCenterId.FUNCTION) {
          QuecUserCenterConfigParser.functionGroup(group, config, business, basic)
        } else if (group.identifier === QuecUserCenterId.OTHER) {
          QuecUserCenterConfigParser.otherGroup(group, config, business)
        }
      }
    } catch (_) {
      QLog.w('QuecUserCenterConfigParser', 'Invalid userCenterConfig JSON')
      return new QuecUserCenterConfigModel()
    }
    return config
  }

  private static group(raw: QuecRawObject): QuecUserCenterMainModel {
    const group: QuecUserCenterMainModel = new QuecUserCenterMainModel()
    group.identifier = R.string(raw, 'identifier', group.identifier)
    group.title = R.string(raw, 'title', group.title)
    for (const item of R.objectArray(raw, 'configs')) {
      const sub: QuecUserCenterSubModel = new QuecUserCenterSubModel()
      sub.identifier = R.string(item, 'identifier', sub.identifier)
      sub.title = R.string(item, 'title', sub.title)
      sub.icon = R.string(item, 'icon', sub.icon)
      sub.panelId = R.number(item, 'panelId', sub.panelId)
      const params: QuecRawObject | undefined = R.object(item, 'params')
      if (params !== undefined) {
        sub.params = new QuecUserCenterSubParamsModel()
        if (params['routerName'] !== undefined && params['routerName'] !== null) {
          sub.params.routerName = R.string(params, 'routerName', '')
        }
        if (params['routerNameSecond'] !== undefined && params['routerNameSecond'] !== null) {
          sub.params.routerNameSecond = R.string(params, 'routerNameSecond', '')
        }
      }
      group.configs.push(sub)
    }
    return group
  }

  private static functionGroup(group: QuecUserCenterMainModel, config: QuecUserCenterConfigModel,
    business: QuecOemBusinessConfigModel, basic: QuecOemBasicConfigModel): void {
    const items: QuecUserCenterSubModel[] = []
    const showDevice: boolean = business.isShowDeviceManager &&
      (basic.appTypeId === ENERGY_APP_TYPE || !business.isHomeList)
    for (const sub of group.configs) {
      if (sub.identifier === QuecUserCenterId.DEVICE && showDevice) {
        config.device = sub
        items.push(sub)
      } else if (sub.identifier === QuecUserCenterId.MESSAGE && business.isShowMessageCenter) {
        config.message = sub
        items.push(sub)
      }
    }
    group.configs = items
    config.function = items.length > 0 ? group : null
  }

  private static otherGroup(group: QuecUserCenterMainModel, config: QuecUserCenterConfigModel,
    business: QuecOemBusinessConfigModel): void {
    const items: QuecUserCenterSubModel[] = []
    for (const sub of group.configs) {
      if (sub.identifier === QuecUserCenterId.SETTING) {
        config.setting = sub
      } else if (sub.identifier === QuecUserCenterId.ABOUT) {
        config.aboutMe = sub
      } else if (sub.identifier === QuecUserCenterId.HELP) {
        config.help = sub
      } else if (sub.identifier === QuecUserCenterId.FEEDBACK && business.isShowFeedback) {
        if (business.quecFeedbackPanel > 0) {
          sub.panelId = business.quecFeedbackPanel
        }
        config.feedback = sub
      } else {
        continue
      }
      items.push(sub)
    }
    group.configs = items
    config.other = items.length > 0 ? group : null
  }
}
