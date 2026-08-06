import { cryptoFramework } from '@kit.CryptoArchitectureKit'
import { util } from '@kit.ArkTS'
import { QuecCodec } from '../codec/QuecCodec'

export class QuecAesUtils {
  private static readonly TRANSFORMATION: string = 'AES128|CBC|PKCS7'
  private static readonly REQUIRED_BYTES: number = 16
  private static readonly BASE64_LINE_LENGTH: number = 76
  private static readonly BASE64 = new util.Base64Helper()

  static encrypt(content: string, key: string, iv: string): string {
    const keyBytes: Uint8Array = QuecCodec.utf8(key)
    const ivBytes: Uint8Array = QuecCodec.utf8(iv)

    QuecAesUtils.validateLength('key', keyBytes)
    QuecAesUtils.validateLength('iv', ivBytes)

    const keyBlob: cryptoFramework.DataBlob = { data: keyBytes }
    const symKey =
      cryptoFramework.createSymKeyGenerator('AES128').convertKeySync(keyBlob)

    const params: cryptoFramework.IvParamsSpec = {
      algName: 'IvParamsSpec',
      iv: { data: ivBytes }
    }

    const cipher =
      cryptoFramework.createCipher(QuecAesUtils.TRANSFORMATION)

    cipher.initSync(
      cryptoFramework.CryptoMode.ENCRYPT_MODE,
      symKey,
      params
    )

    const input: cryptoFramework.DataBlob = {
      data: QuecCodec.utf8(content)
    }
    const encrypted: Uint8Array = cipher.doFinalSync(input).data
    const base64: string = QuecAesUtils.BASE64.encodeToStringSync(
      encrypted,
      util.Type.BASIC
    )

    return QuecAesUtils.formatAndroidBase64(base64)
  }

  static decrypt(content: string, key: string, iv: string): string {
    const keyBytes: Uint8Array = QuecCodec.utf8(key)
    const ivBytes: Uint8Array = QuecCodec.utf8(iv)

    QuecAesUtils.validateLength('key', keyBytes)
    QuecAesUtils.validateLength('iv', ivBytes)

    const keyBlob: cryptoFramework.DataBlob = { data: keyBytes }
    const symKey =
      cryptoFramework.createSymKeyGenerator('AES128').convertKeySync(keyBlob)

    const params: cryptoFramework.IvParamsSpec = {
      algName: 'IvParamsSpec',
      iv: { data: ivBytes }
    }

    const cipher =
      cryptoFramework.createCipher(QuecAesUtils.TRANSFORMATION)

    cipher.initSync(
      cryptoFramework.CryptoMode.DECRYPT_MODE,
      symKey,
      params
    )

    const normalized: string = content.replace(/\s/g, '')
    const encrypted: Uint8Array =
      QuecAesUtils.BASE64.decodeSync(normalized, util.Type.BASIC)
    const encryptedBlob: cryptoFramework.DataBlob = {
      data: encrypted
    }

    return QuecCodec.utf8String(
      cipher.doFinalSync(encryptedBlob).data
    )
  }

  private static validateLength(
    name: string,
    value: Uint8Array
  ): void {
    if (value.length !== QuecAesUtils.REQUIRED_BYTES) {
      throw new Error(`AES ${name} must be exactly 16 UTF-8 bytes`)
    }
  }

  private static formatAndroidBase64(value: string): string {
    let result: string = ''
    for (
      let index: number = 0;
      index < value.length;
      index += QuecAesUtils.BASE64_LINE_LENGTH
    ) {
      result += value.substring(
        index,
        index + QuecAesUtils.BASE64_LINE_LENGTH
      ) + '\n'
    }
    return result
  }
}
