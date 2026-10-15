import { QuecPaaSResponse } from './QuecPaaSResponse'

export interface QuecPaaSPageData<T> {
  total: number
  list: T[]
  pageNum: number
  pageSize: number
  size: number
  startRow: number
  endRow: number
  pages: number
  prePage: number
  nextPage: number
  isFirstPage: boolean
  isLastPage: boolean
  hasPreviousPage: boolean
  hasNextPage: boolean
  navigatePages: number
  navigatepageNums: number[]
  navigateFirstPage: number
  navigateLastPage: number
}

export interface QuecPaaSListResponse<T> extends QuecPaaSResponse<QuecPaaSPageData<T>> {}
