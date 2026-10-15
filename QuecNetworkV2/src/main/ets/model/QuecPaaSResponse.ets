export interface QuecPaaSResponse<T> {
  code: number
  msg: string
  data: T
  extMsg: Object | null
}
