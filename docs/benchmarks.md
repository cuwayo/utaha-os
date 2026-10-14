# Benchmarks

Every number here must come from a real measurement on a real device.
**Do not claim an improvement without numbers.** Baselines are recorded on the
unmodified base before any modification (SPEC §2, §13).

## Targets (SPEC §2)

| Metric | Target |
|---|---|
| Free RAM after boot, idle | ≥ 800 MB on 2 GB device |
| Cold boot time | < 45 s |
| App cold start (Settings, Camera, browser) | ≥ 15% faster than unmodified base |
| Background app retention | ≥ base |
| Idle battery drain overnight | ≤ base (no worse) |
| UI smoothness | no sustained frame drops (launcher scroll, app drawer) |

## Baseline — NOT YET MEASURED

Nothing has been flashed. Fill this in during M0/M1.

| Metric | Base | Unit |
|---|---|---|
| Free RAM after boot, idle | — | MB |
| Cold boot time | — | s |
| Cold start: Settings | — | ms |
| Cold start: Camera | — | ms |
| Cold start: Browser | — | ms |
| Background apps retained | — | count |
| Idle drain overnight (8 h) | — | %/h |
| Frame drops, launcher scroll | — | count |

## Method

Measured with `scripts/collect-benchmarks.sh` on the device (adb). Raw output is
appended below per run. See that script for the exact commands.

### M1 (unmodified base)

_pending — no run yet_
