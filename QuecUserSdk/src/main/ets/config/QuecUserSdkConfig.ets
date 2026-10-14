export class QuecUserSdkConfig {
  readonly userDomain: string
  readonly userDomainSecret: string

  constructor(userDomain: string, userDomainSecret: string) {
    if (userDomain.trim().length === 0) {
      throw new Error('UserDomain must not be empty')
    }
    if (userDomainSecret.trim().length === 0) {
      throw new Error('UserDomainSecret must not be empty')
    }
    this.userDomain = userDomain.trim()
    this.userDomainSecret = userDomainSecret
  }
}