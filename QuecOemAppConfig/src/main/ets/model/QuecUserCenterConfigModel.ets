/**
 * 用户中心子功能参数
 */
export class QuecUserCenterSubParamsModel {
  /** 路由名称 */
  routerName: string | null = null
  /** 第二个路由名称 */
  routerNameSecond: string | null = null
}

/**
 * 用户中心子功能配置
 */
export class QuecUserCenterSubModel {
  /** 功能 id */
  identifier: string = ''
  /** 功能标题 */
  title: string = ''
  /** 功能图标 */
  icon: string = ''
  /** 面板 id */
  panelId: number = 0
  /** 功能参数 */
  params: QuecUserCenterSubParamsModel | null = null
}

/**
 * 用户中心主功能配置
 */
export class QuecUserCenterMainModel {
  /** 功能 id */
  identifier: string = ''
  /** 功能标题 */
  title: string = ''
  /** 子功能配置列表 */
  configs: QuecUserCenterSubModel[] = []
}

/**
 * 用户中心配置。Android 中由 business.userCenterConfig 配合各业务开关派生，当前尚未实现派生逻辑。
 * 未配置或被业务开关关闭的功能为 null。
 */
export class QuecUserCenterConfigModel {
  /** 主功能 -- 用户头像分区 */
  header: QuecUserCenterMainModel | null = null
  /** 主功能 -- 精选服务分区 */
  service: QuecUserCenterMainModel | null = null
  /** 主功能 -- 功能分区 */
  function: QuecUserCenterMainModel | null = null
  /** 主功能 -- 其他分区 */
  other: QuecUserCenterMainModel | null = null
  /** 子功能 -- 电话通知 */
  call: QuecUserCenterSubModel | null = null
  /** 子功能 -- 短信通知 */
  sms: QuecUserCenterSubModel | null = null
  /** 子功能 -- 设备管理 */
  device: QuecUserCenterSubModel | null = null
  /** 子功能 -- 消息中心 */
  message: QuecUserCenterSubModel | null = null
  /** 子功能 -- 设置 */
  setting: QuecUserCenterSubModel | null = null
  /** 子功能 -- 关于我们 */
  aboutMe: QuecUserCenterSubModel | null = null
  /** 子功能 -- 帮助文档 */
  help: QuecUserCenterSubModel | null = null
  /** 子功能 -- 意见反馈 */
  feedback: QuecUserCenterSubModel | null = null
  /** 子功能 -- 门店查询 */
  storeQuery: QuecUserCenterSubModel | null = null
  /** App 设置页面配置 */
  settings: QuecUserCenterMainModel | null = null
  /** 主功能 -- 第三方语音配置 */
  thirdVoice: QuecUserCenterMainModel | null = null
  /** 子功能 -- 电子围栏 */
  electronicFence: QuecUserCenterSubModel | null = null
  /** 主功能 -- 广告 banner 分区 */
  banner: QuecUserCenterMainModel | null = null
  /** 子功能 -- 紧急联系人 */
  sosContact: QuecUserCenterSubModel | null = null
  /** 子功能 -- 设备保养信息 */
  maintenanceInfo: QuecUserCenterSubModel | null = null
  /** 子功能 -- 智能服务 */
  smartService: QuecUserCenterSubModel | null = null
  /** 子功能 -- 服务记录 */
  serviceRecords: QuecUserCenterSubModel | null = null
  /** 子功能 -- 车辆报失 */
  vehicleLossReport: QuecUserCenterSubModel | null = null
  /** 子功能 -- 第三方语音 Alexa */
  thirdVoiceAlexa: QuecUserCenterSubModel | null = null
  /** 子功能 -- 第三方语音 Google Assistant */
  thirdVoiceGoogleAssistant: QuecUserCenterSubModel | null = null
  /** 子功能 -- 骑行勋章 */
  cyclingMedal: QuecUserCenterSubModel | null = null
  /** 子功能 -- 售后服务 */
  afterSalesService: QuecUserCenterSubModel | null = null
  /** 子功能 -- 试驾 */
  testDrive: QuecUserCenterSubModel | null = null
}
