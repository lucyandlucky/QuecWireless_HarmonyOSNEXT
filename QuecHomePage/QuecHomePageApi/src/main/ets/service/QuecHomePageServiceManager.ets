import { HMRouterMgr } from '@hadss/hmrouter'

import { HOME_PAGE_SERVICE, QuecHomePageService } from './QuecHomePageService'

export class QuecHomePageServiceManager {
  private static readonly instance: QuecHomePageServiceManager = new QuecHomePageServiceManager()

  private constructor() {
  }

  public static getInstance(): QuecHomePageServiceManager {
    return QuecHomePageServiceManager.instance
  }

  /** 首页实现未提供服务时返回 undefined，由主容器跳过该 Tab。 */
  public getHomePageBuilder(): WrappedBuilder<[]> | undefined {
    return HMRouterMgr.getService<QuecHomePageService>(HOME_PAGE_SERVICE)?.getPageBuilder()
  }
}
