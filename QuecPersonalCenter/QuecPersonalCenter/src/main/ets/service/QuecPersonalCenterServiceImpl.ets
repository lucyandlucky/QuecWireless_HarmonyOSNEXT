import { HMServiceProvider } from '@hadss/hmrouter'
import { PERSONAL_CENTER_SERVICE, QuecPersonalCenterService } from '@quec/personal-center-api'

import { personalCenterBuilder } from '../builders/PersonalCenterBuilder'

@HMServiceProvider({ serviceName: PERSONAL_CENTER_SERVICE })
export class QuecPersonalCenterServiceImpl implements QuecPersonalCenterService {
  getPageBuilder(): WrappedBuilder<[]> {
    return wrapBuilder(personalCenterBuilder)
  }
}
