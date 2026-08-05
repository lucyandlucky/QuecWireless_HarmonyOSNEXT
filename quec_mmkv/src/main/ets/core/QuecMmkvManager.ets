import { MMKV } from '@tencent/mmkv';
import common from '@ohos.app.ability.common';

export class QuecMmkvManager {
  private static readonly PROCESS_MODE: number = MMKV.MULTI_PROCESS_MODE
  private static initialized: boolean = false
  private static defaultInstance: QuecMmkvManager | undefined = undefined
  private static scopedInstances: Map<string, QuecMmkvManager> = new Map<string, QuecMmkvManager>()
  private readonly mmkv: MMKV

  private constructor(mmkv: MMKV) {
    this.mmkv = mmkv
  }

  static initialize(context: common.ApplicationContext): string {
    if (QuecMmkvManager.initialized) {
      return MMKV.rootDir
    }
    const rootDir = MMKV.initialize(context)

    QuecMmkvManager.defaultInstance = new QuecMmkvManager(MMKV.defaultMMKV(QuecMmkvManager.PROCESS_MODE))
    QuecMmkvManager.initialized = true
    return rootDir
  }

  static isInitialized(): boolean {
    return QuecMmkvManager.initialized
  }

  static getInstance(scope?: string): QuecMmkvManager {
    if (scope === undefined) {
      const instance = QuecMmkvManager.defaultInstance
      if (instance === undefined) {
        throw new Error('The default MMKV instance is undefined.')
      }
      return instance
    }

    const scopeId = scope.trim()
    if (scopeId.length === 0) {
      throw new Error('MMKV scope must not be empty.')
    }

    const cached = QuecMmkvManager.scopedInstances.get(scopeId)

    if (cached !== undefined) {
      return cached
    }
    const instance = new QuecMmkvManager(MMKV.mmkvWithID(scopeId, QuecMmkvManager.PROCESS_MODE))
    QuecMmkvManager.scopedInstances.set(scopeId, instance)

    return instance
  }

  get mmapId(): string {
    return this.mmkv.mmapID
  }

  public putBoolean(key: string, value: boolean): boolean {
    this.validateKey(key)
    return this.mmkv.encodeBool(key, value)
  }

  public getBoolean(key: string, defaultValue: boolean = false): boolean {
    this.validateKey(key)
    return this.mmkv.decodeBool(key, defaultValue) ?? defaultValue
  }

  public putString(key: string, value: string): boolean {
    this.validateKey(key)
    return this.mmkv.encodeString(key, value)
  }

  public getString(key: string, defaultValue: string = ''): string {
    this.validateKey(key)
    return this.mmkv.decodeString(key, defaultValue) ?? defaultValue
  }

  public putInt(key: string, value: number): boolean {
    this.validateKey(key)
    return this.mmkv.encodeInt32(key, value)
  }

  public getInt(key: string, defaultValue: number = 0
  ): number {
    this.validateKey(key)
    return this.mmkv.decodeInt32(key, defaultValue) ?? defaultValue
  }

  public putFloat(key: string, value: number): boolean {
    this.validateKey(key)
    return this.mmkv.encodeFloat(key, value)
  }

  public getFloat(key: string, defaultValue: number = 0): number {
    this.validateKey(key)

    return this.mmkv.decodeFloat(key, defaultValue) ?? defaultValue
  }

  public putLong(key: string, value: bigint): boolean {
    this.validateKey(key)
    return this.mmkv.encodeInt64(key, value)
  }

  public getLong(key: string, defaultValue: bigint): bigint {
    this.validateKey(key)

    return this.mmkv.decodeInt64(key, defaultValue) ?? defaultValue
  }

  public putDouble(key: string, value: number): boolean {
    this.validateKey(key)
    return this.mmkv.encodeDouble(key, value)
  }

  public getDouble(key: string, defaultValue: number = 0): number {
    this.validateKey(key)

    return this.mmkv.decodeDouble(key, defaultValue) ?? defaultValue
  }

  public putStringSet(key: string, value: string[]): boolean {
    this.validateKey(key)
    return this.mmkv.encodeStringSet(key, value)
  }

  public getStringSet(key: string, defaultValue: string[] = []): string[] {
    this.validateKey(key)
    return this.mmkv.decodeStringSet(key, defaultValue) ?? defaultValue
  }

  public contains(key: string): boolean {
    this.validateKey(key)
    return this.mmkv.containsKey(key)
  }

  public remove(key: string): void {
    this.validateKey(key)
    this.mmkv.removeValueForKey(key)
  }

  public removeValues(keys: string[]): void {
    for (const key of keys) {
      this.validateKey(key)
    }
    this.mmkv.removeValuesForKeys(keys)
  }

  public clearAll(keepSpace: boolean = false): void {
    this.mmkv.clearAll(keepSpace)
  }

  public allKeys(): string[] {
    return this.mmkv.allKeys()
  }

  public count(): bigint {
    return this.mmkv.count()
  }

  public static clearScope(scope: string, keepSpace: boolean = false): void {
    QuecMmkvManager.getInstance(scope).clearAll(keepSpace)
  }

  public static removeScope(scope: string): boolean {
    QuecMmkvManager.ensureInitialzed()
    const scopeId = scope.trim()

    if (scopeId.length === 0) {
      throw new Error('MMKV scope must not be empty')
    }

    QuecMmkvManager.scopedInstances.delete(scopeId)
    return MMKV.removeStorage(scopeId)
  }


  private validateKey(key: string): void {
    if (key.trim().length === 0) {
      throw new Error('MMKV key must not be empty')
    }
  }

  private static ensureInitialzed(): void {
    if (!QuecMmkvManager.initialized) {
      throw new Error('QuecMmkvManager.initialize() must be called before use')
    }
  }
}