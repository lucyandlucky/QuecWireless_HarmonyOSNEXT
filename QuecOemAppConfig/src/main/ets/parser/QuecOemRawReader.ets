export type QuecRawValue = Object | null | undefined

export type QuecRawObject = Record<string, QuecRawValue>

/**
 * Reads untyped YAML values with Gson-like coercion, so the parsed result matches Android:
 * missing or null fields fall back to defaults, numeric strings such as '271' become numbers,
 * and numbers become strings for string fields.
 */
export class QuecOemRawReader {
  private static get(raw: QuecRawObject | undefined, key: string): QuecRawValue {
    return raw === undefined ? undefined : raw[key]
  }

  public static asObject(value: QuecRawValue): QuecRawObject | undefined {
    if (value === null || value === undefined || typeof value !== 'object' || Array.isArray(value)) {
      return undefined
    }
    return value as QuecRawObject
  }

  public static object(raw: QuecRawObject | undefined, key: string): QuecRawObject | undefined {
    return QuecOemRawReader.asObject(QuecOemRawReader.get(raw, key))
  }

  /**
   * Reads a list of mappings. Elements that are not mappings are skipped, so a malformed entry
   * cannot break the whole list.
   */
  public static objectArray(raw: QuecRawObject | undefined, key: string): QuecRawObject[] {
    const value: QuecRawValue = QuecOemRawReader.get(raw, key)
    if (!Array.isArray(value)) {
      return []
    }
    const items: QuecRawObject[] = []
    for (const element of value as QuecRawValue[]) {
      const item: QuecRawObject | undefined = QuecOemRawReader.asObject(element)
      if (item !== undefined) {
        items.push(item)
      }
    }
    return items
  }

  public static string(raw: QuecRawObject | undefined, key: string, defaultValue: string): string {
    const value: QuecRawValue = QuecOemRawReader.get(raw, key)
    if (typeof value === 'string') {
      return value
    }
    if (typeof value === 'number' || typeof value === 'boolean') {
      return String(value)
    }
    return defaultValue
  }

  public static number(raw: QuecRawObject | undefined, key: string, defaultValue: number): number {
    const value: QuecRawValue = QuecOemRawReader.get(raw, key)
    if (typeof value === 'number') {
      return Number.isFinite(value) ? value : defaultValue
    }
    if (typeof value === 'string' && value.trim().length > 0) {
      const parsed: number = Number(value.trim())
      return Number.isFinite(parsed) ? parsed : defaultValue
    }
    return defaultValue
  }

  public static boolean(raw: QuecRawObject | undefined, key: string, defaultValue: boolean): boolean {
    const value: QuecRawValue = QuecOemRawReader.get(raw, key)
    if (typeof value === 'boolean') {
      return value
    }
    // The config platform writes some booleans as 'true' / 'false', like business.isChina.
    if (typeof value === 'string') {
      const text: string = value.trim().toLowerCase()
      if (text === 'true') {
        return true
      }
      if (text === 'false') {
        return false
      }
    }
    return defaultValue
  }
}
