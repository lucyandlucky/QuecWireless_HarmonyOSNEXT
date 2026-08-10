import { QuecFormBody, QuecTokenManager } from 'quec_network'
import { QuecUserSdkConfig } from '../config/QuecUserSdkConfig'
import { QuecLoginTokenData, QuecUserModel } from '../model/QuecUserModel'
import { QuecLoginRequestBuilder } from '../utils/QuecLoginRequestBuilder'
import { QuecUserApi, QuecUserDataSource } from './QuecUserApi'

export class QuecUserService {
  private static instance: QuecUserService | undefined
  private readonly loginBuilder: QuecLoginRequestBuilder
  private readonly dataSource: QuecUserDataSource
  private currentUser: QuecUserModel | undefined

  private constructor(config: QuecUserSdkConfig) {
    this.loginBuilder = new QuecLoginRequestBuilder(config)
    this.dataSource = new QuecUserApi()
  }

  private static getInstance(): QuecUserService {
    const instance: QuecUserService | undefined = QuecUserService.instance
    if (instance === undefined) {
      throw new Error('QuecUserService.initialize() must be called before use')
    }
    return instance
  }

  private saveToken(data: QuecLoginTokenData): void {
    const saved: boolean = QuecTokenManager.saveToken(
      data.accessToken.token,
      data.refreshToken.token,
      data.accessToken.expirationTime,
      data.refreshToken.expirationTime
    )
    if (!saved) {
      throw new Error('Failed to save login token')
    }
  }

  private async fetchUserInfo(): Promise<QuecUserModel> {
    const user: QuecUserModel = await this.dataSource.getUserInfo()
    this.currentUser = user
    return user
  }

  private async finishLogin(data: QuecLoginTokenData): Promise<void> {
    this.saveToken(data)
    this.currentUser = undefined
    await this.fetchUserInfo()
  }

  public static initialize(config: QuecUserSdkConfig): void {
    QuecUserService.instance = new QuecUserService(config)
  }

  public static isLogin(): boolean {
    return QuecTokenManager.isLogin()
  }

  public static getToken(): string {
    return QuecTokenManager.getAccessToken()
  }

  public static async loginByEmail(email: string, password: string): Promise<void> {
    const service: QuecUserService = QuecUserService.getInstance()
    const formBody: QuecFormBody =
      service.loginBuilder.buildEmailPasswordLogin(email, password)
    const tokenData: QuecLoginTokenData = await service.dataSource.loginByEmail(formBody)
    await service.finishLogin(tokenData)
  }

  public static async loginByPhone(
    phone: string,
    password: string,
    internationalCode?: string
  ): Promise<void> {
    const service: QuecUserService = QuecUserService.getInstance()
    const formBody: QuecFormBody = service.loginBuilder.buildPhonePasswordLogin(
      phone,
      password,
      internationalCode
    )
    const tokenData: QuecLoginTokenData = await service.dataSource.loginByPhone(formBody)
    await service.finishLogin(tokenData)
  }

  public static getUserModel(): QuecUserModel | undefined {
    return QuecUserService.getInstance().currentUser
  }

  public static getUserInfo(): Promise<QuecUserModel> {
    return QuecUserService.getInstance().fetchUserInfo()
  }
}
