export interface QuecApiResponse<T> {
  code: number
  data?: T | null
  msg?: string
  subCode?: number
}
