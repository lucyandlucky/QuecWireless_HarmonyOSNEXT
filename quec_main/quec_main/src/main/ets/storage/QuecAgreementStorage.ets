import { QuecMmkvManager } from 'quec_mmkv';
import { QuecMainStorageKeys } from '../constants/QuecMainStorageKeys';

export class QuecAgreementStorage {
  static hasAgreed(): boolean {
    return QuecMmkvManager
      .getInstance()
      .getBoolean(QuecMainStorageKeys.HAS_AGREE_USER_AGREEMENT, false)
  }

  static setHasAgreed(val: boolean): boolean {
    return QuecMmkvManager
      .getInstance()
      .putBoolean(QuecMainStorageKeys.HAS_AGREE_USER_AGREEMENT, val)
  }

  static clear(): void {
    QuecMmkvManager
      .getInstance()
      .remove(QuecMainStorageKeys.HAS_AGREE_USER_AGREEMENT)
  }
}