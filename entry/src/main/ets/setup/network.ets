import { QuecNetworkV2 } from 'quec_network_v2'

const BASE_URL: string = 'https://iot-api.quectelcn.com'

export function setupNetwork(): void {
  QuecNetworkV2.init({ baseURL: BASE_URL })
}
