# @quec/oem-app-config

Partial HarmonyOS port of Android `com.quectel.app.basic:quec-oem-config:3.8.0.004-SNAPSHOT`. It currently reads only the top-level fields (`configId`, `version`, `platform`), `basic`, and `network`. The configuration file is `entry/src/main/resources/rawfile/config/app_config.yml`, copied unchanged from the Android app.

## Usage

`QuecAbilityStage.onCreate` calls `QuecOemConfigManager.parseRawFileConfig(context, 'config/app_config.yml')`, the counterpart of Android `parseAssetConfigFile`. After that, read the static fields, as on Android:

```typescript
QuecOemAppConfig.configId
QuecOemAppConfig.basic.area
QuecOemAppConfig.basic.appVersion
QuecOemAppConfig.network.china.baseUrl
```

`parseConfigContent(source)` parses YAML text directly.

## Behavior

- Types follow the Android models. Quoted numbers such as `configId: '271'` become numbers. Numbers become strings in string fields; for example, `appVersionCode: 1` becomes `'1'`.
- Missing or `null` fields, and missing sections, keep the Android default values, for example `configId = 111` and `platform = 'android'`. Every field holds its default before parsing.
- YAML fields outside the parsed sections are ignored.
- `parseRawFileConfig` logs failures through `QLog` and does not throw. `parseConfigContent` throws if the YAML is not a mapping, and the current configuration stays unchanged.

## Not parsed yet

The model types are all present, but only the top-level fields, `basic`, and `network` are parsed and exposed on `QuecOemAppConfig`.

- `QuecOemBusinessConfigModel` and `QuecOemThirdPlatformConfigModel` describe the `business` and `thirdPlatform` sections. Both are plain field mappings: add a parser method and a static field when they are needed.
- `QuecOemAppTab`, `QuecUserCenterConfigModel`, and `QuecThirdVoiceConfig` are derived on Android rather than read directly: `appTab` comes from `appTabBarConfig` or the `business.appTab` JSON, `userCenter` comes from the `business.userCenterConfig` JSON filtered by the business switches, and `thirdVoiceConfig` comes from `business.alexaConfig` and `business.googleAssistantConfig`. Porting these also means porting the Android derivation logic.

Also not ported: the utility classes (`QuecOemConfigUtil`, `QuecDarkModeUtil`, `QuecUserCenterConfigUtil`), `isHaveSmart`, and decryption of the encrypted configuration format, where Android decrypts files starting with `Base64("quectel")` using AES/ECB/PKCS7. Port these from the Android sources when they are needed.
