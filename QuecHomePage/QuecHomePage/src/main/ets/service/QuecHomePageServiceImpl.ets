import { HMServiceProvider } from '@hadss/hmrouter'
import { HOME_PAGE_SERVICE, QuecHomePageService } from '@quec/home-page-api'

import { homePageBuilder } from '../builders/HomePageBuilder'

/** 主容器按服务名获取首页构建器，页面状态由首页组件持有。 */
@HMServiceProvider({ serviceName: HOME_PAGE_SERVICE })
export class QuecHomePageServiceImpl implements QuecHomePageService {
  getPageBuilder(): WrappedBuilder<[]> {
    return wrapBuilder(homePageBuilder)
  }
}
