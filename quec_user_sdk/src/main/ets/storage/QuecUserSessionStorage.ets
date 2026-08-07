import { QuecMmkvManager } from 'quec_mmkv'
import { QuecLoginTokenData } from '../model/QuecUserModel'

export class QuecUserSessionStorage {
  private static readonly SCOPE: string = 'quec_user_sdk'
  private static readonly ACCESS_TOKEN: string = 'access_token'
  private static readonly REFRESH_TOKEN: string = 'refresh_token'
  private static readonly ACCESS_EXPIRATION: string = 'access_token_expiration'
  private static readonly REFRESH_EXPIRATION: string = 'refresh_token_expiration'

  private static get storage(): QuecMmkvManager {
    return QuecMmkvManager.getInstance(QuecUserSessionStorage.SCOPE)
  }

  static saveTokens(data: QuecLoginTokenData): boolean {
    const storage = QuecUserSessionStorage.storage
    const accessSaved: boolean = storage.putString(QuecUserSessionStorage.ACCESS_TOKEN, data.accessToken.token)
    const refreshSaved: boolean = storage.putString(QuecUserSessionStorage.REFRESH_TOKEN, data.refreshToken.token)
    const accessExpirationSaved: boolean =
      storage.putDouble(QuecUserSessionStorage.ACCESS_EXPIRATION, data.accessToken.expirationTime)
    const refreshExpirationSaved: boolean =
      storage.putDouble(QuecUserSessionStorage.REFRESH_EXPIRATION, data.refreshToken.expirationTime)

    const saved = accessSaved && refreshSaved && accessExpirationSaved && refreshExpirationSaved
    if (!saved) {
      QuecUserSessionStorage.clearSession()
    }
    return saved
  }

  static getAccessToken(): string {
    return QuecUserSessionStorage.storage.getString(QuecUserSessionStorage.ACCESS_TOKEN)
  }

  static getRefreshToken(): string {
    return QuecUserSessionStorage.storage.getString(QuecUserSessionStorage.REFRESH_TOKEN)
  }

  static getAccessTokenExpiration(): number {
    return QuecUserSessionStorage.storage.getDouble(QuecUserSessionStorage.ACCESS_EXPIRATION, -1)
  }

  static getRefreshTokenExpiration(): number {
    return QuecUserSessionStorage.storage.getDouble(QuecUserSessionStorage.REFRESH_EXPIRATION, -1)
  }

  static isLogin(): boolean {
    return QuecUserSessionStorage.getAccessToken().trim().length > 0
  }

  static clearSession(): void {
    QuecUserSessionStorage.storage.removeValues([
      QuecUserSessionStorage.ACCESS_TOKEN,
      QuecUserSessionStorage.REFRESH_TOKEN,
      QuecUserSessionStorage.ACCESS_EXPIRATION,
      QuecUserSessionStorage.REFRESH_EXPIRATION
    ])
  }
}