# Third-party licenses

Per SPEC §13. Every third-party component we ship must be listed here with its
license. **Nothing is added without a verified license.** Empty until M2.

## Project itself

| Component | License | Source |
|---|---|---|
| Utaha OS changes | TBD (choose: Apache-2.0 recommended for Android ROM) | this repo |

## Upstream components

| Component | License | Source | Verified |
|---|---|---|---|
| LineageOS device tree (`Mi8937`, `mithorium-common`) | Apache-2.0 | github.com/LineageOS | _pending_ |
| LineageOS kernel (`android_kernel_xiaomi_msm8937`) | GPL-2.0 | github.com/LineageOS | _pending_ |
| TheMuppets vendor blobs (`Mi8917`) | proprietary (extracted) | github.com/TheMuppets | _pending_ |
| AOSP | Apache-2.0 | source.android.com | _pending_ |

## To check before shipping (SPEC §7)

- Fonts (e.g. Roboto Flex) — confirm the license permits redistribution.
- Launcher (Lawnchair / Launcher3) — GPL-3.0 / Apache-2.0 respectively; verify.
- Boot animation, wallpapers, ringtones — must be open-licensed or original.
- Any chromatix / camera tuning blobs — usually proprietary; document their origin.
