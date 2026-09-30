# quec-oem-app-config

The source of truth is `entry/src/main/resources/rawfile/config/app_config.yml`. It is copied from the Android application's current `app_config.yml` without changing its fields or values, including `platform: android`.

At startup, `EntryAbility` loads and parses the YAML through `QuecOemAppConfig.initialize(resourceManager)`. The parsed configuration is stored directly and is available through `QuecOemAppConfig.get()`; no business module consumes it yet. This stage does not select a network region or validate individual configuration fields.

The YAML does not change `AppScope/app.json5`, ability metadata, localized app names, or icon resources in this stage. Those application settings remain managed by the existing Harmony project files.
