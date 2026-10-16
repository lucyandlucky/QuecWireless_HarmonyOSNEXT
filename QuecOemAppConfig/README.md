# @quec/oem-app-config

Partial HarmonyOS port of Android `com.quectel.app.basic:quec-oem-config:3.8.0.004-SNAPSHOT`. It reads the top-level fields (`configId`, `version`, `platform`), `basic`, `network`, bottom tabs, and the business fields needed by the personal center's basic menus. The configuration file is `entry/src/main/resources/rawfile/config/app_config.yml`, copied unchanged from the Android app.

## Reading the configuration

Business code reads through `QuecGlobalConfig`, which exposes the configuration of the region in use:

```typescript
QuecGlobalConfig.network.baseUrl      // 当前区域
QuecGlobalConfig.network.userDomain
QuecGlobalConfig.basic.appVersion
QuecGlobalConfig.configId
QuecGlobalConfig.region               // QuecRegion.CHINA / EUROPE / NORTH_AMERICA
QuecGlobalConfig.appTab.tabs
QuecGlobalConfig.userCenter.other     // 已过滤关闭功能的菜单分组
```

Only `network` depends on the region; `basic` and the top-level fields are single values in the YAML and are forwarded as they are. Use `QuecOemAppConfig` directly only when a specific region is needed, for example `QuecOemAppConfig.network.europe.loginStid`.

`QuecGlobalConfig` is not a port of Android's `GlobalConfig`. Every member is a getter that reads through to `QuecOemAppConfig`, so it holds no copy of the configuration. Do not add mutable fields to it, and do not add `getBaseXxxUrl()`-style helpers: the former creates a second source of truth, while building request URLs belongs to `QuecApiUrl` in `@quec/network-v2`.

## Startup

```typescript
QuecMmkvManager.init(applicationContext)
QuecOemConfigManager.init(applicationContext)   // 解析 YAML，写入 QuecOemAppConfig
QuecGlobalConfig.init()                          // 选区域，回写 service_type
```

The order matters: region selection reads `basic.area` from the parsed configuration and the saved `service_type` from MMKV.

`QuecOemConfigManager.parseConfigContent(source)` also accepts YAML text directly.

## Parsers

`QuecOemConfigManager` reads the YAML and writes the parsed models to `QuecOemAppConfig`.
Each configuration section has its own parser with a `parse(...)` entry point:

- `QuecOemBasicConfigParser`: basic fields and the nested app name.
- `QuecOemNetworkConfigParser`: network fields for all three regions.
- `QuecOemBusinessConfigParser`: the supported business fields.
- `QuecOemAppTabConfigParser`: bottom tabs, preferring `appTabBarConfig` and falling back to the JSON in `business.appTab`.
- `QuecUserCenterConfigParser`: personal-center menus derived from the parsed basic and business models.

Parsers return models. Shared type conversion and default-value handling stay in `QuecOemRawReader`.

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

## Personal center

The parsed business fields are `appTab`, `userCenterConfig`, `isHomeList`, `isShowDeviceManager`, `isShowMessageCenter`, `isShowFeedback`, and `quecFeedbackPanel`. Other business fields still hold their model defaults.

`QuecUserCenterConfigParser` reads the header, function, and other groups from `business.userCenterConfig`. Function items require their corresponding business switches; device management also requires `basic.appTypeId === 1166110884101666 || !business.isHomeList`. Feedback uses `quecFeedbackPanel` when it is positive. Disabled or unsupported items are removed from `configs`, group order within `configs` is retained, and empty menu groups become `null`. The individual fields such as `device` and `feedback` refer to the same objects as the filtered groups.

Missing or invalid user-center JSON produces an empty model without adding hardcoded menus. Invalid JSON is logged without printing the configuration contents. Banner, selected services, third-party voice, medals, and their switches are not parsed yet.

## Not parsed yet

The remaining business fields and `QuecOemThirdPlatformConfigModel` are not parsed. `QuecThirdVoiceConfig` will also require deriving configuration from `business.alexaConfig` and `business.googleAssistantConfig`.

Also not ported: the utility classes (`QuecOemConfigUtil`, `QuecDarkModeUtil`, `QuecUserCenterConfigUtil`), `isHaveSmart`, and decryption of the encrypted configuration format, where Android decrypts files starting with `Base64("quectel")` using AES/ECB/PKCS7. Port these from the Android sources when they are needed.
