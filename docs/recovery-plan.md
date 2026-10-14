# Recovery plan — ugglite (postmarketOS → MIUI → LineageOS)

**READ THIS BEFORE FLASHING ANYTHING.** Written from verified sources; every
claim is tagged **[CONFIRMED]** (official page/repo loaded) or **[UNVERIFIED]**
(secondary source / inference). Do not treat unverified items as safe.

---

## 0. Current device state

- Bootloader **unlocked** (user-confirmed).
- Runs **postmarketOS**, no Android installed.
- postmarketOS installation on this device **requires lk2nd** — the pmOS wiki
  states verbatim: *"Flashing **lk2nd** is required, as it is a hard dependency.
  Without it the mainline kernel will not select the display panel (resulting in
  black screen on boot)."* **[CONFIRMED]**
- lk2nd is written to the **`boot`** partition, not `aboot`. It is packed into an
  Android boot image and loaded by the stock bootloader; it does **not** replace
  the stock bootloader. **[CONFIRMED]**

### Why this matters for us

Because lk2nd sits in `boot`, and because lk2nd **intercepts** `fastboot flash
boot` (it writes the image at a **+512 KiB offset** inside `boot`, deliberately
so it does not overwrite itself) **[CONFIRMED]** — flashing a LineageOS
`boot.img` while booted into *lk2nd's* fastboot will **not** replace lk2nd.

**Flashing a full stock MIUI fastboot ROM is the clean way out**, because it
writes a stock `boot.img` at offset 0, removing lk2nd, and restores the whole
firmware chain. That is the recommended path (and matches the plan already in
progress: MIUI 11).

---

## 1. STEP 0 — Back up device-unique partitions (DO THIS FIRST)

These carry calibration and identity data that **cannot be regenerated**:

| Partition | Holds | Loss consequence |
|---|---|---|
| `persist` | sensor calibration, Wi-Fi/BT MAC | Wi-Fi/BT MAC becomes invalid |
| `modemst1`, `modemst2` | modem NV / IMEI-related | **IMEI lost → no calls/data** |
| `fsg`, `fsc` | modem filesystem / calibration | modem instability |

Partition names confirmed from the device's own TWRP fstab
(`TeamWin/android_device_xiaomi_ugglite`), under
`/dev/block/bootdevice/by-name/`. **[CONFIRMED]**

Back them up from a root shell (MIUI `su`, or TWRP):

```sh
mkdir -p /sdcard/utaha-backup
for p in persist modemst1 modemst2 fsg fsc; do
  dd if=/dev/block/bootdevice/by-name/$p of=/sdcard/utaha-backup/$p.img
done
ls -l /sdcard/utaha-backup/
```

On postmarketOS the same partitions appear as
`/dev/disk/by-partlabel/<name>` **[UNVERIFIED]**.

**Then copy the backup OFF the device** (`adb pull /sdcard/utaha-backup`) and keep
it somewhere safe. A backup on the phone dies with the phone.

> The `dd` commands are the standard method; the partition *paths* are
> [CONFIRMED], the one-liners are not quoted from an official ugglite page.

---

## 2. STEP 1 — Check anti-rollback (ARB) before downgrading anything

ARB is Xiaomi's rollback-index mechanism. If triggered it is a **hard,
unrecoverable brick** requiring EDL. **[CONFIRMED]** (XDA, Mishaal Rahman, 2018).

```sh
fastboot getvar anti
```

- **Blank output** → ARB not enabled on this unit.
- **A number** → that is the rollback index; only flash ROMs whose index is `>=`.

**Whether ugglite (MSM8917) has ARB at all is [UNVERIFIED].** It is a 2017
budget SoC and the documented rollout targeted Mi 8 / Redmi Note 5 Pro class
devices. Do not assume either way — just run the command and record the result.

⚠️ **Never downgrade via TWRP on an ARB-enabled device** — TWRP does not check
the index, which is how most ARB bricks happened. **[CONFIRMED]**

Since we are restoring *forward* to stock V11.x, ARB is unlikely to bite.

---

## 3. STEP 2 — Flash stock MIUI 11 (removes lk2nd, restores firmware)

**MIUI 11 for ugglite is Android 7.1 (Nougat)** — the ROM filename encodes
`_7.1_` (verified: `ugglite_global_images_V11.0.3.0.NDFMIXM_...\_7.1_global`).
Note this differs from the Android 13 we are ultimately building.

> Correction: an earlier note in this project said MIUI 11 on ugglite was
> Android 9. That was wrong — it is **Android 7.1**. The stock ROM therefore
> ships the 3.18 kernel the SPEC originally described; the 4.9/4.19 kernels are
> the *LineageOS* ones, not stock.

### Where to get it

Exact codename to search: **`ugglite`** (also `HMNote5ALITE` in Xiaomi filenames).

Official Xiaomi CDN (HTTP 200, ~1.94 GB) **[CONFIRMED]**:

- Global: `https://bigota.d.miui.com/V11.0.3.0.NDFMIXM/ugglite_global_images_V11.0.3.0.NDFMIXM_20191022.0000.00_7.1_global_9e48e63f94.tgz`
- China: `https://bigota.d.miui.com/V11.0.2.0.NDFCNXM/ugglite_images_V11.0.2.0.NDFCNXM_20191018.0000.00_7.1_cn_1a8ee1cb2d.tgz`

⚠️ **`xiaomifirmwareupdater.com` is dead** — it now serves a domain-parking page.
**[CONFIRMED]** Use the CDN links above or the Wayback Machine.

### What flashing it restores

A **full** fastboot ROM writes `boot` (removing lk2nd), `recovery`, `system`,
`cust`, `splash`, **and** the firmware chain. The firmware partitions confirmed
from the ROM's own `updater-script` **[CONFIRMED]**:

```
aboot, sbl1, tz, rpm, keymaster, cmnlib, cmnlib64, devcfg  (+ each *bak)
modem (NON-HLOS.bin), dsp (adspso.bin)
```

Use Mi Flash (Windows) or the ROM's `flash_all` script. **[UNVERIFIED]** —
the click-by-click Mi Flash procedure was not verified for this device.

⚠️ **Do not use Mi Flash's "clean all and lock" option** — it re-locks the
bootloader. **[UNVERIFIED]** but standard practice; choose "clean all" only.

---

## 4. STEP 3 — Verify MIUI booted, then capture device facts

**This is the last chance to read stock-only facts** (stock CPU ABI, MIUI build
identity, camera sensor identity). Run:

```sh
./scripts/capture-device-facts.sh > facts.txt
```

Enable USB debugging first: Settings → About phone → tap *MIUI version* 7× →
Developer options → USB debugging.

---

## 5. STEP 4 — Flash LineageOS / Utaha

Once stock MIUI is confirmed booting:

1. **Boot TWRP without flashing it** (safer first test):
   ```sh
   fastboot boot twrp-3.6.2_9-0-ugglite.img
   ```
   TWRP for ugglite is official: `dl.twrp.me/ugglite/` **[CONFIRMED]**.

2. **Back up EFS/Persist from TWRP** if not already done in Step 0.

3. **Flash our build**:
   ```sh
   fastboot flash recovery <recovery.img>
   # then, from recovery, flash the ROM zip (adb sideload or sdcard)
   ```
   ugglite has **no A/B slots** — there is no `_a`/`_b` partition scheme.
   **[CONFIRMED]** So there is no slot juggling; one `boot` and one `system`.

4. Keep the stock MIUI fastboot ROM on hand as the fallback throughout.

---

## 6. EDL — last resort, do not rely on it

- Open-source tooling exists (`bkerler/edl`), and a `msm8917` programmer set is
  present publicly. **[CONFIRMED]**
- **But** the public MSM8917 files are `..._peek.bin` (peek/limited) programmers,
  and Xiaomi EDL authentication is real — `bkerler/Loaders` has a
  `xiaomi/EDLAuth/` directory, and the `edl` README notes EDL auth is unsupported
  on some Xiaomi devices. **[CONFIRMED]**
- **Whether EDL write works without authorization on ugglite is [UNVERIFIED].**
  Treat EDL as **possibly blocked**. This is exactly why Step 0 (backups) and the
  stock ROM fallback matter.
- lk2nd can jump to EDL if installed: `fastboot oem reboot-edl`. **[CONFIRMED]**

---

## 7. Known unknowns (do not paper over these)

| Item | Status |
|---|---|
| Exact ugglite `flash_all.sh` contents | **[UNVERIFIED]** — ROM too large to fetch here |
| Whether Mi Flash re-locks the bootloader | **[UNVERIFIED]** |
| Whether ugglite has ARB enabled | **[UNVERIFIED]** — check with `fastboot getvar anti` |
| Whether EDL works unauthenticated on this unit | **[UNVERIFIED]** |
| Whether flashing stock preserves unlock state | **[UNVERIFIED]** (commonly yes) |

---

## Sources loaded

lk2nd `README.md` + `Documentation/{devices,boot,fastboot,targets}.md`; pmOS/Nura
wiki pages for *Xiaomi Redmi Note 5A (xiaomi-ugglite)*, *qcom-msm89x7*,
*Lk2nd/lk1st*, *Installation*; pmbootstrap `pmb/flasher/frontend.py`;
`bigota.d.miui.com` ROM URLs (HEAD 200); XFU `firmware_xiaomi_ugglite` +
downloaded `updater-script`; `mirom.ezbox.idv.tw/en/phone/ugglite/`; XDA
*"Xiaomi's Anti-Rollback Explained"*; `bkerler/edl` README + `bkerler/Loaders`;
`dl.twrp.me/ugglite/`; `TeamWin/android_device_xiaomi_ugglite` fstab.
