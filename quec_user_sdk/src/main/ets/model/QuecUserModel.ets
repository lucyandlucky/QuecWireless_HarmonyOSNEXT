export interface QuecTokenInfo {
  token: string
  expirationTime: number
}

export interface QuecLoginTokenData {
  accessToken: QuecTokenInfo
  refreshToken: QuecTokenInfo
}

export interface QuecUserModel {
  nikeName?: string | null
  phone?: string | null
  registerTime?: string | null
  sex?: string | null
  sexValue?: string | null
  timezone?: string | null
  uid?: string | null
  wchartId?: string | null
  wchartName?: string | null
  address?: string | null
  email?: string | null
  headimg?: string | null
  lang?: string | null
  lastLoginTime?: string | null
  nationality?: string | null
  alipayUserId?: string | null
  appleUserId?: string | null
  city?: string | null
  facebookUserId?: string | null
  logonMode?: number | null
  province?: string | null
  qqUserId?: string | null
  remark?: string | null
  signature?: string | null
  status?: number | null
  twitterUserId?: string | null
  wechatMiniprogramUserId?: string | null
  wechatOffiaccountUserId?: string | null
  wechatUnionId?: string | null
  isOnlyLogin?: boolean | null
  isSetPwd?: boolean | null
  googleUserId?: string | null
}
