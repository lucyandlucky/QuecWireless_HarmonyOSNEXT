export interface QuecTokenInfo {
  token: string
  expirationTime: number
}

export interface QuecLoginTokenData {
  accessToken: QuecTokenInfo
  refreshToken: QuecTokenInfo
}

export interface QuecUserModel {
  uid?: string
  nikeName?: string
  phone?: string
  email?: string
  headimg?: string
  sex?: string
  timezone?: string
  nationality?: string
  isOnlyLogin?: boolean
  isSetPwd?: boolean
}