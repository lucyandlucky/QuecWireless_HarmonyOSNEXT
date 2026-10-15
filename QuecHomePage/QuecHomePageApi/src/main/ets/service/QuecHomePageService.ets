export const HOME_PAGE_SERVICE: string = 'quec.tab.home_page'

/** 首页模块对主容器提供的能力，不依赖首页实现或路由框架。 */
export interface QuecHomePageService {
  getPageBuilder(): WrappedBuilder<[]>
}
