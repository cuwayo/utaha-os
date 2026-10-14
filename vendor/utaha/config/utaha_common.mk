#
# Utaha OS — common product configuration
# Included by device product makefiles (lineage_<target>.mk).
#
# M2 (rebranding) work. The PROPERTY values and overrides below are the
# intended shape; they are NOT yet verified against the chosen LineageOS branch
# and MUST be checked before M2 (SPEC §13: verify property names against live sources).
#

# --- Identity ---------------------------------------------------------------
PRODUCT_BRAND := Utaha
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := Redmi Note 5A (Utaha OS)

# Version shown in Settings -> About phone
UTAHA_VERSION_MAJOR := 0
UTAHA_VERSION_MINOR := 1
UTAHA_VERSION_PATCH := 0
UTAHA_VERSION_CODENAME := M0-feasibility
UTAHA_VERSION := $(UTAHA_VERSION_MAJOR).$(UTAHA_VERSION_MINOR).$(UTAHA_VERSION_PATCH)-$(UTAHA_VERSION_CODENAME)
UTAHA_BUILD_DATE := $(shell date -u +%Y%m%d)

# --- Utaha properties -------------------------------------------------------
PRODUCT_PRODUCT_PROPERTIES += \
    ro.utaha.version=$(UTAHA_VERSION) \
    ro.utaha.build.date=$(UTAHA_BUILD_DATE) \
    ro.utaha.device=ugglite

# --- Material You -----------------------------------------------------------
# Native monet is available (base is Android 16). Default seed colour: violet.
# The actual RRO overlays live in vendor/utaha/overlay/ (added in M2).
PRODUCT_PRODUCT_PROPERTIES += \
    ro.utaha.monet.seed=violet

# --- Low-RAM / Android Go (SPEC §8) -----------------------------------------
# These are the *intended* values. Each must be measured before/after in
# docs/benchmarks.md. Do not enable blindly.
PRODUCT_PRODUCT_PROPERTIES += \
    ro.config.low_ram=true

# --- No GApps by default (SPEC §8, §14.5) -----------------------------------
# Default is none. microG/Play are opt-in, added as a separate product flavour.

# --- Cheap visuals (SPEC §7) ------------------------------------------------
PRODUCT_PRODUCT_PROPERTIES += \
    ro.utaha.animation.scale=0.5
