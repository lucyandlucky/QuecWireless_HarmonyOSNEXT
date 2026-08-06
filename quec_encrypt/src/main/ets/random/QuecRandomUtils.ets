import { cryptoFramework } from '@kit.CryptoArchitectureKit'

export class QuecRandomUtils {
  private static readonly CHARACTERS: string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  private static readonly ACCEPT_LIMIT: number = 248

  static randomAlphaNumeric(length: number): string {
    if (length <= 0) {
      throw new Error('Random string length must be greater than 0')
    }

    try {
      const random = cryptoFramework.createRandom()
      let result: string = ''

      while (result.length < length) {
        const remaining: number = length - result.length
        const bytes: Uint8Array = random.generateRandomSync(Math.max(remaining * 2, 16)).data

        for (let i = 0; i < bytes.length && result.length < length; i++) {
          if (bytes[i] < QuecRandomUtils.ACCEPT_LIMIT) {
            const charIndex: number = bytes[i] % QuecRandomUtils.CHARACTERS.length
            result += QuecRandomUtils.CHARACTERS.charAt(charIndex)
          }
        }
      }
      return result
    } catch (error) {
      const randomError: Error = error as Error
      throw new Error(`Failed to generate secure random string: ${randomError.message}`)
    }
  }

  static randomLen16(): string {
    return QuecRandomUtils.randomAlphaNumeric(16)
  }
}
