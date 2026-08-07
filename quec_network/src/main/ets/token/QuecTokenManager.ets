import { QuecMmkvManager } from 'quec_mmkv'

export class QuecTokenManager {
  private static readonly SCOPE: string = 'quec_network'
  private static readonly ACCESS_TOKEN: string = 'access_token'
  private static readonly REFRESH_TOKEN: string = 'refresh_token'
  private static readonly ACCESS_EXPIRATION: string = 'access_token_expiration'
  private static readonly REFRESH_EXPIRATION: string = 'refresh_token_expiration'

  private static get storage(): QuecMmkvManager {
    return QuecMmkvManager.getInstance(QuecTokenManager.SCOPE)
  }

  static saveToken(
    accessToken: string,
    refreshToken: string,
    accessExpirationTime: number,
    refreshExpirationTime: number): boolean {

    if (accessToken.trim().length === 0 || refreshToken.trim().length === 0) {
      throw new Error('Access token and refresh token must not be empty')
    }

    if (!Number.isFinite(accessExpirationTime) ||
      !Number.isFinite(refreshExpirationTime) ||
      accessExpirationTime <= 0 ||
      refreshExpirationTime <= 0
    ) {
      throw new Error('Token expiration time must be a positive number')
    }

    const storage = QuecTokenManager.storage
    const accessSaved: boolean = storage.putString(QuecTokenManager.ACCESS_TOKEN, accessToken)
    const refreshSaved: boolean = storage.putString(QuecTokenManager.REFRESH_TOKEN, refreshToken)
    const accessExpirationSaved: boolean =
      storage.putDouble(QuecTokenManager.ACCESS_EXPIRATION, accessExpirationTime)
    const refreshExpirationSaved: boolean =
      storage.putDouble(QuecTokenManager.REFRESH_EXPIRATION, refreshExpirationTime)

    const saved = accessSaved && refreshSaved && accessExpirationSaved && refreshExpirationSaved
    if (!saved) {
      QuecTokenManager.clearToken()
    }
    return saved
  }

  static getAccessToken(): string {
    return QuecTokenManager.storage.getString(QuecTokenManager.ACCESS_TOKEN)
  }

  static getRefreshToken(): string {
    return QuecTokenManager.storage.getString(QuecTokenManager.REFRESH_TOKEN)
  }

  static getAccessTokenExpirationTime(): number {
    return QuecTokenManager.storage.getDouble(QuecTokenManager.ACCESS_EXPIRATION, -1)
  }

  static getRefreshTokenExpirationTime(): number {
    return QuecTokenManager.storage.getDouble(QuecTokenManager.REFRESH_EXPIRATION, -1)
  }

  static isLogin(): boolean {
    return QuecTokenManager.getAccessToken().trim().length > 0
  }

  static clearToken(): void {
    QuecTokenManager.storage.removeValues([
      QuecTokenManager.ACCESS_TOKEN,
      QuecTokenManager.REFRESH_TOKEN,
      QuecTokenManager.ACCESS_EXPIRATION,
      QuecTokenManager.REFRESH_EXPIRATION
    ])
  }
}