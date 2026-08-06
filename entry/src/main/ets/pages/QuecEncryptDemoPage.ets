import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  QuecAesUtils,
  QuecCodec,
  QuecDigestUtils,
  QuecRandomUtils
} from 'quec_encrypt'

const DOMAIN: number = 0x0000
const TAG: string = 'QuecEncryptDemo'
const AES_KEY: string = '53135C61D6B5274A'
const AES_IV: string = 'D6B5274A53135C61'
const AES_CONTENT: string = '123456'
const AES_RESULT: string = 'aZRR/pADbIpSaV28IOCP3g==\n'

class EncryptDemoResult {
  name: string
  input: string
  expected: string
  actual: string
  passed: boolean
  errorMessage: string

  constructor(
    name: string,
    input: string,
    expected: string,
    actual: string,
    passed: boolean,
    errorMessage: string = ''
  ) {
    this.name = name
    this.input = input
    this.expected = expected
    this.actual = actual
    this.passed = passed
    this.errorMessage = errorMessage
  }
}

@Entry
@ComponentV2
struct QuecEncryptDemoPage {
  @Local private results: Array<EncryptDemoResult> = []
  @Local private isRunning: boolean = false

  aboutToAppear(): void {
    this.runAllCases()
  }

  private runAllCases(): void {
    this.results = []
    this.isRunning = true

    this.runCase(
      'UTF-8 encode',
      'A中',
      '41E4B8AD',
      (): string => QuecCodec.toHex(QuecCodec.utf8('A中'), true)
    )
    this.runCase(
      'UTF-8 decode',
      '41E4B8AD',
      'A中',
      (): string => QuecCodec.utf8String(QuecCodec.utf8('A中'))
    )
    this.runCase(
      'MD5',
      'abc',
      '900150983CD24FB0D6963F7D28E17F72',
      (): string => QuecDigestUtils.md5('abc')
    )
    this.runCase(
      'MD5 middle 16',
      'abc',
      '3CD24FB0D6963F7D',
      (): string => QuecDigestUtils.md5By16('abc')
    )
    this.runCase(
      'SHA-256',
      'abc',
      'ba7816bf8f01cfea414140de5dae2223' +
      'b00361a396177a9cb410ff61f20015ad',
      (): string => QuecDigestUtils.sha256('abc')
    )
    this.runCase(
      'AES-128-CBC encrypt',
      AES_CONTENT,
      AES_RESULT,
      (): string => QuecAesUtils.encrypt(AES_CONTENT, AES_KEY, AES_IV)
    )
    this.runCase(
      'AES-128-CBC decrypt',
      AES_RESULT,
      AES_CONTENT,
      (): string => QuecAesUtils.decrypt(AES_RESULT, AES_KEY, AES_IV)
    )
    this.runCase(
      'AES Android Base64 wrapping',
      '64 ASCII characters',
      '76,32,0',
      (): string => {
        const longContent: string =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        const encrypted: string = QuecAesUtils.encrypt(
          longContent,
          AES_KEY,
          AES_IV
        )
        const lines: Array<string> = encrypted.split('\n')
        return `${lines[0].length},${lines[1].length},${lines[2].length}`
      }
    )

    const utf8Content: string = '移联万物 QuecWireless'
    this.runCase(
      'AES UTF-8 round trip',
      utf8Content,
      utf8Content,
      (): string => QuecAesUtils.decrypt(
        QuecAesUtils.encrypt(utf8Content, AES_KEY, AES_IV),
        AES_KEY,
        AES_IV
      )
    )
    this.runRandomCase()

    this.isRunning = false
    const summary: string = JSON.stringify({
      total: this.results.length,
      passed: this.passedCount(),
      failed: this.results.length - this.passedCount()
    })
    console.info(`[${TAG}] summary=${summary}`)
    hilog.info(DOMAIN, TAG, 'summary=%{public}s', summary)
  }

  private runCase(
    name: string,
    input: string,
    expected: string,
    action: () => string
  ): void {
    try {
      const actual: string = action()
      this.appendResult(new EncryptDemoResult(
        name,
        input,
        expected,
        actual,
        actual === expected
      ))
    } catch (error) {
      const demoError: Error = error as Error
      this.appendResult(new EncryptDemoResult(
        name,
        input,
        expected,
        '',
        false,
        demoError.message
      ))
    }
  }

  private runRandomCase(): void {
    const name: string = 'Secure random string'
    const expected: string = '16 alphanumeric characters'
    try {
      const actual: string = QuecRandomUtils.randomLen16()
      const passed: boolean = actual.length === 16 &&
        /^[0-9A-Za-z]{16}$/.test(actual)
      this.appendResult(new EncryptDemoResult(
        name,
        'length=16',
        expected,
        actual,
        passed
      ))
    } catch (error) {
      const demoError: Error = error as Error
      this.appendResult(new EncryptDemoResult(
        name,
        'length=16',
        expected,
        '',
        false,
        demoError.message
      ))
    }
  }

  private appendResult(result: EncryptDemoResult): void {
    this.results = [...this.results, result]
    const output: string = JSON.stringify(result)
    console.info(`[${TAG}] result=${output}`)
    hilog.info(DOMAIN, TAG, 'result=%{public}s', output)
  }

  private passedCount(): number {
    return this.results.filter((result: EncryptDemoResult): boolean => result.passed).length
  }

  private displayValue(value: string): string {
    return value.replace(/\r/g, '\\r').replace(/\n/g, '\\n')
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('Quec Encrypt Demo')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#080F19')
          Text(`${this.passedCount()} / ${this.results.length} passed`)
            .fontSize(14)
            .fontColor('#62666D')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button(this.isRunning ? 'Running' : 'Run again')
          .enabled(!this.isRunning)
          .onClick(() => {
            this.runAllCases()
          })
      }
      .width('100%')

      Scroll() {
        Column({ space: 10 }) {
          ForEach(
            this.results,
            (result: EncryptDemoResult) => {
              Column({ space: 6 }) {
                Row({ space: 8 }) {
                  Text(result.passed ? 'PASS' : 'FAIL')
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(result.passed ? '#16834A' : '#C3362B')
                  Text(result.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#080F19')
                    .layoutWeight(1)
                }
                .width('100%')

                Text(`Input: ${this.displayValue(result.input)}`)
                  .fontSize(13)
                  .fontColor('#62666D')
                  .width('100%')
                Text(`Expected: ${this.displayValue(result.expected)}`)
                  .fontSize(13)
                  .fontColor('#62666D')
                  .width('100%')
                Text(`Actual: ${this.displayValue(result.actual)}`)
                  .fontSize(13)
                  .fontColor('#080F19')
                  .width('100%')
                if (result.errorMessage.length > 0) {
                  Text(`Error: ${result.errorMessage}`)
                    .fontSize(13)
                    .fontColor('#C3362B')
                    .width('100%')
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(12)
              .backgroundColor(result.passed ? '#F2FAF5' : '#FFF3F1')
              .borderRadius(6)
            },
            (result: EncryptDemoResult): string => result.name
          )
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 20, bottom: 16 })
    .backgroundColor('#FFFFFF')
  }
}
