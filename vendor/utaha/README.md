# vendor/utaha

Utaha OS branding layer: product makefiles, resource overlays (RRO), default
apps, boot animation, wallpapers, fonts.

```
vendor/utaha/
  config/     product makefiles (utaha_ugglite.mk, utaha_common.mk)
  overlay/    RRO overlays (SystemUI, Settings, framework-res, launcher) — M2
  apps/       bundled apps — M3
  fonts/      open-licensed fonts — M2
  bootanim/   boot animation — M2
```

**Status: M0 scaffold.** Only `config/` exists. Everything is a placeholder and
must be verified against the synced LineageOS tree before use.
