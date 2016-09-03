export ARCHS = arm64 armv7
export TARGET = iphone:9.2:7.0

include theos/makefiles/common.mk

TWEAK_NAME = NoYahooTWC
NoYahooTWC_FILES = Tweak.xm
NoYahooTWC_FRAMEWORKS = UIKit
NoYahooTWC_LDFLAGS += -Wl,-segalign,4000

VERSION.INC_BUILD_NUMBER = 1

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	plutil -convert binary1 $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/NoYahooTWC.plist
	chmod 0644 $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/NoYahooTWC.plist
	find $(THEOS_STAGING_DIR) -exec touch -r $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/NoYahooTWC.dylib {} \;
	find $(THEOS_STAGING_DIR) -name ".*" -exec rm -f {} \;

after-package::
	rm -fr .theos/packages/*
