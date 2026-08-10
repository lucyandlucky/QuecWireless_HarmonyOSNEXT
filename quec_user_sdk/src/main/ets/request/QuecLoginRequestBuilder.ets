import { QuecDigestUtils } from 'quec_encrypt';
import { QuecFormBody } from 'quec_network';
import { QuecUserSdkConfig } from '../config/QuecUserSdkConfig';
import { QuecEncryptedPassword, QuecPasswordEncryptor } from '../crypto/QuecPasswordEncryptor';

export class QuecLoginRequestBuilder {
  private readonly config: QuecUserSdkConfig

  constructor(config: QuecUserSdkConfig) {
    this.config = config
  }

  public buildEmailPasswordLogin(email: string, password: string): QuecFormBody {
    if (email.trim().length === 0) {
      throw new Error('Email must not be empty')
    }

    const encrypted: QuecEncryptedPassword = QuecPasswordEncryptor.encrypt(password)

    const signatureSource: string =
      email + encrypted.encryptedPassword + encrypted.random + this.config.userDomainSecret
    const signature: string = QuecDigestUtils.sha256(signatureSource)

    if (signature.length === 0) {
      throw new Error('Failed to generate email login signature')
    }

    const formBody: QuecFormBody = {}
    formBody['email'] = email
    formBody['pwd'] = encrypted.encryptedPassword
    formBody['random'] = encrypted.random
    formBody['userDomain'] = this.config.userDomain
    formBody['signature'] = signature

    return formBody
  }

  public buildPhonePasswordLogin(
    phone: string,
    password: string,
    internationalCode?: string
  ): QuecFormBody {
    if (phone.trim().length === 0) {
      throw new Error('Phone must not be empty')
    }
    const normalizedCode: string = this.normalizedInternationalCode(internationalCode)
    const encrypted: QuecEncryptedPassword = QuecPasswordEncryptor.encrypt(password)
    const signatureSource: string =
      normalizedCode + phone + encrypted.encryptedPassword + encrypted.random + this.config.userDomainSecret
    const signature: string = QuecDigestUtils.sha256(signatureSource)

    if (signature.length === 0) {
      throw new Error('Failed to generate phone login signature')
    }

    const formBody: QuecFormBody = {}
    if (normalizedCode.length > 0) {
      formBody['internationalCode'] = normalizedCode
    }
    formBody['phone'] = phone
    formBody['pwd'] = encrypted.encryptedPassword
    formBody['random'] = encrypted.random
    formBody['userDomain'] = this.config.userDomain
    formBody['signature'] = signature

    return formBody

  }

  private normalizedInternationalCode(value?: string): string {
    return value?.split('+').join('') ?? ''
  }
}