import { QuecMmkvManager } from 'quec_mmkv'
import { QuecFormBody, QuecTokenManager } from 'quec_network'
import { QuecUserSdkConfig } from '../config/QuecUserSdkConfig'
import { QuecUserConstants } from '../constants/QuecUserConstants'
import { QuecLoginTokenData, QuecUserModel } from '../model/QuecUserModel'
import { QuecLoginRequestBuilder } from '../utils/QuecLoginRequestBuilder'
import { QuecUserApi, QuecUserDataSource } from './QuecUserApi'
import { JSON } from '@kit.ArkTS'

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
    const uidSaved: boolean = QuecMmkvManager
      .getInstance()
      .putString(
        QuecUserConstants.KEY_USER_UID,
        user.uid ?? ''
      )
    const modelSaved: boolean = QuecMmkvManager
      .getInstance()
      .putString(
        QuecUserConstants.KEY_USER_MODEL,
        JSON.stringify(user)
      )
    if (!uidSaved || !modelSaved) {
      throw new Error('Failed to save user information')
    }
    this.currentUser = user
    return user
  }

  private async finishLogin(data: QuecLoginTokenData): Promise<void> {
    this.saveToken(data)
    this.currentUser = undefined
    await this.fetchUserInfo()
  }

  private loadCachedUser(): QuecUserModel | undefined {
    const cached: string = QuecMmkvManager
      .getInstance()
      .getString(QuecUserConstants.KEY_USER_MODEL)

    if (cached.length === 0) {
      return undefined
    }

    try {
      const parsed: Object | null = JSON.parse(cached)
      if (parsed === null) {
        return undefined
      }
      const user: QuecUserModel = parsed as QuecUserModel
      this.currentUser = user
      return user
    } catch (error) {
      QuecMmkvManager
        .getInstance()
        .remove(QuecUserConstants.KEY_USER_MODEL)
      return undefined
    }
  }

  private clearLoginInfo(): void {
    QuecTokenManager.clearToken()
    QuecMmkvManager.getInstance()
      .removeValues([
        QuecUserConstants.KEY_USER_UID,
        QuecUserConstants.KEY_USER_MODEL
      ])
    this.currentUser = undefined
  }

  public static async logout(): Promise<void> {
    const service: QuecUserService = QuecUserService.getInstance()
    await service.dataSource.logout()
    service.clearLoginInfo()
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
    const service = QuecUserService.getInstance()

    if (service.currentUser !== undefined) {
      return service.currentUser
    }
    return service.loadCachedUser()
  }

  public static getUserInfo(): Promise<QuecUserModel> {
    return QuecUserService.getInstance().fetchUserInfo()
  }
}
