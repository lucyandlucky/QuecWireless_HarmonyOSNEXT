# quec_log

`QLog` is the shared app log entry point. Its fixed HiLog domain is `0x514C` (shown as `A0514C` in logs). Call `QLog.init(applicationContext, defaultTag)` during application startup, then use `v`, `d`, `i`, `w`, or `e` with either a message or a tag and message. `e` also accepts an `Error` and prints its stack when available.

Messages are written to both HiLog and `@ohos/xlog`. XLog uses an async instance and flushes synchronously after each message under `applicationContext.filesDir/xlog/log` and `applicationContext.filesDir/xlog/cache`, with the `QuecWireless` filename prefix. The compressed `.xlog` files are not plain text. `QLog.flush()` is also available before exporting logs. HarmonyOS has no separate verbose HiLog level, so `v` uses debug in HiLog and verbose in XLog. HTTP request formatting remains in `quec_network_v2` and its output goes through `QLog`; log export and upload are not part of this module yet.
