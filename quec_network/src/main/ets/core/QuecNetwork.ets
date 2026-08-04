import { QuecNetworkConfig } from '../config/QuecNetworkConfig';
import { QuecNetworkConstants } from '../constants/QuecNetworkConstants';
import { QuecNetworkError, QuecNetworkErrorType } from '../error/QuecNetworkError';
import { QuecHttpClient } from './QuecHttpClient';

export class QuecNetwork {
  private static client: QuecHttpClient | undefined

  private constructor() {
  }

  public static initialize(config: QuecNetworkConfig): void {
    QuecNetwork.client = new QuecHttpClient(config)
  }

  public static isInitialized(): boolean {
    return QuecNetwork.client !== undefined
  }

  public static getClient(): QuecHttpClient {
    const client: QuecHttpClient | undefined = QuecNetwork.client

    if (client === undefined) {
      throw new QuecNetworkError(
        QuecNetworkErrorType.REQUEST_ILLEGAL,
        QuecNetworkConstants.UNKNOWN_ERROR_CODE,
        'QuecNetwork must be initialized before use'
      )
    }

    return client
  }
}
