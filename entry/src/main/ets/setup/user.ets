import { QuecUserSdkConfig, QuecUserService } from 'quec_user_sdk'

const USER_DOMAIN: string = 'C.DM.5903.1'
const USER_DOMAIN_SECRET: string = 'EufftRJSuWuVY7c6txzGifV9bJcfXHAFa7hXY5doXSn7'

export function setupUserSdk(): void {
  QuecUserService.initialize(new QuecUserSdkConfig(USER_DOMAIN, USER_DOMAIN_SECRET))
}