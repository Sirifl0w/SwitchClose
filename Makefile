ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:5.0

THEOS_BUILD_DIR = debs

include theos/makefiles/common.mk

TWEAK_NAME = SwitchClose
SwitchClose_CFLAGS = -fno-objc-arc
SwitchClose_FILES = SwitchClose.xm
SwitchClose_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
