#
# Utaha OS — product makefile for ugglite
#
# Target name: utaha_ugglite
#   breakfast utaha_ugglite-userdebug
#
# Inherits the upstream LineageOS device product, then applies Utaha branding.
#
# STATUS: base branch DECIDED = lineage-20 (Android 13).
# The inherit-product target below was verified to exist on lineage-20
# (device/xiaomi/Mi8937/lineage_Mi8917.mk returns HTTP 200). It still needs to
# be confirmed against the actual synced tree before the first build.
#

# Inherit from the upstream device product for the Mi8917 variant (ugglite).
$(call inherit-product, device/xiaomi/Mi8937/lineage_Mi8917.mk)

# Utaha common configuration (branding, props, Material You, low-RAM)
$(call inherit-product, vendor/utaha/config/utaha_common.mk)

# --- Product identity -------------------------------------------------------
PRODUCT_NAME := utaha_ugglite
PRODUCT_DEVICE := Mi8917
PRODUCT_BRAND := Utaha
PRODUCT_MODEL := Redmi Note 5A (Utaha OS)
PRODUCT_MANUFACTURER := Xiaomi

# OTA must accept the real device codename
PRODUCT_OTA_PUBLIC_KEYS := $(PRODUCT_OTA_PUBLIC_KEYS)

# --- Packages ---------------------------------------------------------------
# M3 (debloat) will trim this list. Placeholder: keep the minimal set
# (SPEC §8) — Settings, Dialer, Messages, Contacts, Camera, Gallery, Files,
# Browser, Clock. Actual overrides added in M3 after auditing the base.
