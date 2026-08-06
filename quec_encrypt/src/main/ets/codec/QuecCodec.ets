import { buffer } from '@kit.ArkTS'

export class QuecCodec {
  static utf8(value: string): Uint8Array {
    const encoded: buffer.Buffer = buffer.from(value, 'utf-8')
    const result: Uint8Array = new Uint8Array(encoded.length)
    encoded.copy(result)
    return result
  }

  static utf8String(value: Uint8Array): string {
    return buffer.from(value).toString('utf-8')
  }

  static toHex(value: Uint8Array, uppercase: boolean = false): string {
    let result: string = ''
    for (let index = 0; index < value.length; index++) {
      const hex: string = value[index].toString(16)
      result += hex.length === 1 ? `0${hex}` : hex
    }
    return uppercase ? result.toUpperCase() : result
  }
}
