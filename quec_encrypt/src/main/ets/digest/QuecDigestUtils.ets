import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { QuecCodec } from '../codec/QuecCodec';

export class QuecDigestUtils {
  private static digest(
    algorithm: string,
    value: string,
    uppercase: boolean): string {
    try {
      const md = cryptoFramework.createMd(algorithm)
      const input: cryptoFramework.DataBlob = {
        data: QuecCodec.utf8(value)
      }
      md.updateSync(input)
      return QuecCodec.toHex(md.digestSync().data, uppercase)
    } catch (error) {
      const digestError: Error = error as Error
      console.error(`Failed to calculate ${algorithm} digest: ${digestError.message}`)
      return ''
    }
  }

  static md5(value: string): string {
    return QuecDigestUtils.digest('MD5', value, true)
  }

  static md5By16(value: string): string {
    return QuecDigestUtils.md5(value).substring(8, 24)
  }

  static sha256(value: string): string {
    return QuecDigestUtils.digest('SHA256', value, false)
  }
}
