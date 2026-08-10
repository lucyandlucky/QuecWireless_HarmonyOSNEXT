import { QuecFormBody, QuecTokenManager } from 'quec_network'
import { QuecUserSdkConfig } from '../config/QuecUserSdkConfig'
import { QuecLoginTokenData } from '../model/QuecUserModel'
import { QuecLoginRequestBuilder } from '../request/QuecLoginRequestBuilder'
import { QuecUserApi, QuecUserDataSource } from './QuecUserApi'

export class QuecUserService {
  private static instance: QuecUserService | undefined
  private readonly loginBuilder: QuecLoginRequestBuilder
  private readonly dataSource: QuecUserDataSource

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
    service.saveToken(tokenData)
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
    service.saveToken(tokenData)
  }
}