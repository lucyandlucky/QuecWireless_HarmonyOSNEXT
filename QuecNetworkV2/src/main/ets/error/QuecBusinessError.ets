export class QuecBusinessError extends Error {
  readonly code: number
  readonly subCode: number

  constructor(code: number, message: string, subCode: number = -1) {
    super(message)
    this.code = code
    this.subCode = subCode
  }
}
