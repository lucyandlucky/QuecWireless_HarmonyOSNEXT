import { QuecAesUtils, QuecDigestUtils, QuecRandomUtils } from 'quec_encrypt'

export class QuecEncryptedPassword {
  readonly random: string
  readonly encryptedPassword: string

  constructor(random: string, encryptedPassword: string) {
    this.random = random
    this.encryptedPassword = encryptedPassword
  }
}

export class QuecPasswordEncryptor {
  static encrypt(password: string): QuecEncryptedPassword {
    if (password.length === 0) {
      throw new Error('Password must not be empty')
    }
    const random: string = QuecRandomUtils.randomLen16()
    const aesKey: string = QuecDigestUtils.md5By16(random)

    if (aesKey.length !== 16) {
      throw new Error('Failed to derive the AES key')
    }

    const firstPart: string = aesKey.substring(0, 8)
    const secondPart: string = aesKey.substring(8, 16)
    const aesIv: string = secondPart + firstPart

    const encryptedPassword: string = QuecAesUtils.encrypt(password, aesKey, aesIv)

    if (encryptedPassword.length === 0) {
      throw new Error('Failed to encrypt password')
    }

    return new QuecEncryptedPassword(random, encryptedPassword)
  }
}