export ARCHS = arm64 armv7s armv7
export TARGET = iphone:7.0:7.0

include theos/makefiles/common.mk

TWEAK_NAME = NoYahoo
NoYahoo_FILES = Tweak.xm
NoYahoo_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	chmod 0644 _/Library/MobileSubstrate/DynamicLibraries/NoYahoo.plist
	plutil -convert binary1 _/Library/MobileSubstrate/DynamicLibraries/NoYahoo.plist
	find _ -exec touch -r _/Library/MobileSubstrate/DynamicLibraries/NoYahoo.dylib {} \;
        
after-package::
	rm -fr .theos/packages/*
