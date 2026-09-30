# quec_log

`QLog` is the shared app log entry point. Call `QLog.init(domain, defaultTag)` during application startup, then use `v`, `d`, `i`, `w`, or `e` with either a message or a tag and message. `e` also accepts an `Error` and prints its stack when available.

This first stage writes public messages to HiLog. HarmonyOS has no separate verbose HiLog level, so both `v` and `d` use debug. HTTP request logging remains in `quec_network_v2` for now; file logging and upload are not part of this module yet.
