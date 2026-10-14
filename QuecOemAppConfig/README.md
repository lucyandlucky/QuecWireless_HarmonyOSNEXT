# @quec/oem-app-config

Partial HarmonyOS port of Android `com.quectel.app.basic:quec-oem-config:3.8.0.004-SNAPSHOT`. It currently reads only the top-level fields (`configId`, `version`, `platform`), `basic`, and `network`. The configuration file is `entry/src/main/resources/rawfile/config/app_config.yml`, copied unchanged from the Android app.

## Reading the configuration

Business code reads through `QuecGlobalConfig`, which exposes the configuration of the region in use:

```typescript
QuecGlobalConfig.network.baseUrl      // 当前区域
QuecGlobalConfig.network.userDomain
QuecGlobalConfig.basic.appVersion
QuecGlobalConfig.configId
QuecGlobalConfig.region               // QuecRegion.CHINA / EUROPE / NORTH_AMERICA
```

Only `network` depends on the region; `basic` and the top-level fields are single values in the YAML and are forwarded as they are. Use `QuecOemAppConfig` directly only when a specific region is needed, for example `QuecOemAppConfig.network.europe.loginStid`.

`QuecGlobalConfig` is not a port of Android's `GlobalConfig`. Every member is a getter that reads through to `QuecOemAppConfig`, so it holds no copy of the configuration. Do not add mutable fields to it, and do not add `getBaseXxxUrl()`-style helpers: the former creates a second source of truth, the latter is covered by the axios `baseURL`.

## Startup

```typescript
QuecMmkvManager.init(applicationContext)
QuecOemConfigManager.init(applicationContext)   // 解析 YAML，写入 QuecOemAppConfig
QuecGlobalConfig.init()                          // 选区域，回写 service_type
```

The order matters: region selection reads `basic.area` from the parsed configuration and the saved `service_type` from MMKV.

`QuecOemConfigManager.parseConfigContent(source)` parses YAML text directly and is what the unit tests use.

## Region selection

`QuecGlobalConfig.resolve(area, saved)` is a pure function and keeps Android's branch order, which must not be reordered:

1. `area === 'china'` → `CHINA`, the saved value is ignored.
2. Otherwise the saved `service_type` wins, North America before Europe.
3. With no valid saved value, fall back on `area`: `europe` → `EUROPE`, anything else → `NORTH_AMERICA`.

The saved default is `0` (China), so on a non-China app's first launch neither of the first two branches matches and the `area` fallback applies. `init()` writes `service_type` back on every launch, like Android's `configServiceType`.

`service_type` is persisted so that the region a user picks on the country selection screen survives a restart. That screen is not ported yet, so for now the saved value always equals the `area` fallback.

Switching regions at runtime (Android `ConstantUtil.refreshBasicUrl`) is not implemented: there is no country selection screen yet. It will need a `switchRegion` plus re-running `setupNetwork()` and `setupUserSdk()`.

## Behavior

- Types follow the Android models. Quoted numbers such as `configId: '271'` become numbers. Numbers become strings in string fields; for example, `appVersionCode: 1` becomes `'1'`.
- Missing or `null` fields, and missing sections, keep the Android default values, for example `configId = 111` and `platform = 'android'`. Every field holds its default before parsing.
- YAML fields outside the parsed sections are ignored.
- `QuecOemConfigManager.init` logs failures through `QLog` and does not throw. `parseConfigContent` throws if the YAML is not a mapping, and the current configuration stays unchanged.
- When parsing fails, `basic.area` is empty and the region falls back to North America, matching Android. `QuecGlobalConfig.init()` logs a warning in that case so the cause is visible.

## Not parsed yet

The model types are all present, but only the top-level fields, `basic`, and `network` are parsed.

- `QuecOemBusinessConfigModel` and `QuecOemThirdPlatformConfigModel` describe the `business` and `thirdPlatform` sections. Both are plain field mappings: add a parser method, and a getter on `QuecGlobalConfig`, when they are needed. They are deliberately absent from `QuecGlobalConfig` for now so that callers cannot read empty defaults by mistake.
- `QuecOemAppTab`, `QuecUserCenterConfigModel`, and `QuecThirdVoiceConfig` are derived on Android rather than read directly: `appTab` comes from `appTabBarConfig` or the `business.appTab` JSON, `userCenter` comes from the `business.userCenterConfig` JSON filtered by the business switches, and `thirdVoiceConfig` comes from `business.alexaConfig` and `business.googleAssistantConfig`. Porting these also means porting the Android derivation logic.

Also not ported: the utility classes (`QuecOemConfigUtil`, `QuecDarkModeUtil`, `QuecUserCenterConfigUtil`), `isHaveSmart`, and decryption of the encrypted configuration format, where Android decrypts files starting with `Base64("quectel")` using AES/ECB/PKCS7. Port these from the Android sources when they are needed.
