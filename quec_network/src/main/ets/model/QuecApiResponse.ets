export interface QuecApiResponse<T> {
  code: number
  msg: string
  data: T | null
  subCode?: number
}