# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)
$(call inherit-product, vendor/pixys/build/core/pixys_version.mk)

PRODUCT_BRAND ?= PixysOS

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
endif

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/addon.d/50-superior.sh

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif

# Some permissions
PRODUCT_COPY_FILES += \
    vendor/pixys/config/permissions/privapp-permissions-lineagehw.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-lineagehw.xml \
    vendor/pixys/config/permissions/org.lineageos.health.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/org.lineageos.health.xml

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/pixys/config/permissions/backup.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/backup.xml

# Charger
PRODUCT_PACKAGES += \
    product_charger_res_images

# Copy all Pixys-specific init rc files
$(foreach f,$(wildcard vendor/pixys/prebuilt/common/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Enable Android Beam on all targets
PRODUCT_COPY_FILES += \
    vendor/pixys/config/permissions/android.software.nfc.beam.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.nfc.beam.xml

# Enable one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# Pixys permissions
PRODUCT_COPY_FILES += \
    vendor/pixys/config/permissions/privapp-permissions-pixys-system.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-pixys.xml \
    vendor/pixys/config/permissions/privapp-permissions-pixys-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-pixys-product.xml

# Disable remote keyguard animation
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.wm.enable_remote_keyguard_animation=0

# Log privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=log

# Inherit Pixys audio files
$(call inherit-product, vendor/pixys/config/pixys_audio.mk)

# Inherit Pixys extra packages
$(call inherit-product, vendor/pixys/config/pixys_packages.mk)

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA ?= true
SYSTEMUI_OPTIMIZE_JAVA ?= true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# Dedupe VNDK libraries with identical core variants
TARGET_VNDK_USE_CORE_VARIANT := true

# Use a generic profile based boot image by default
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := art/build/boot/boot-image-profile.txt

# Bootanimation
$(call inherit-product, vendor/pixys/bootanimation/bootanimation.mk)

# Fonts
$(call inherit-product, vendor/pixys/config/fonts.mk)

# Quick Tap
ifeq ($(TARGET_SUPPORTS_QUICK_TAP),true)
PRODUCT_COPY_FILES += \
    vendor/pixys/prebuilt/common/etc/sysconfig/quick_tap.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/quick_tap.xml
endif

# Enable gestural navigation overlay to match default navigation mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.boot.vendor.overlay.theme=com.android.internal.systemui.navbar.gestural

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

# Root
PRODUCT_PACKAGES += \
    adb_root

# ART
# Optimize everything for preopt
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := everything
# Don't preopt prebuilts
DONT_DEXPREOPT_PREBUILTS := true

# SystemUI
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI \

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed

ifeq ($(TARGET_SUPPORTS_64_BIT_APPS), true)
# Use 64-bit dex2oat for better dexopt time.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.dex2oat64.enabled=true
endif

PRODUCT_PROPERTY_OVERRIDES += \
    pm.dexopt.boot=verify \
    pm.dexopt.first-boot=verify \
    pm.dexopt.install=speed-profile \
    pm.dexopt.bg-dexopt=everything

ifneq ($(AB_OTA_PARTITIONS),)
PRODUCT_PROPERTY_OVERRIDES += \
    pm.dexopt.ab-ota=quicken
endif

# Pixel customization
TARGET_SUPPORTS_GOOGLE_BATTERY ?= false

# faceunlock
TARGET_FACE_UNLOCK_SUPPORTED ?= true
ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)

PRODUCT_PACKAGES += \
    ParanoidSense

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.face.sense_service=$(TARGET_FACE_UNLOCK_SUPPORTED)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
endif

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/pixys/overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/pixys/overlay/common

# Pixel Framework
$(call inherit-product, vendor/pixel-framework/config.mk)

# Microsoft
$(call inherit-product-if-exists, vendor/microsoft/packages.mk)

-include $(WORKSPACE)/build_env/image-auto-bits.mk
