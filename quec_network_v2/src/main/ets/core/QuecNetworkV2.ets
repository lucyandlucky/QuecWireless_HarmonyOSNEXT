import axios, { AxiosInstance, CreateAxiosDefaults } from '@ohos/axios'

export class QuecNetworkV2 {
  private constructor() {
  }

  public static createClient(config: CreateAxiosDefaults): AxiosInstance {
    return axios.create(config)
  }
}