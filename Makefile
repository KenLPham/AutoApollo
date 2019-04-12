include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoApollo2
AutoApollo2_FILES = Tweak.xm $(wildcard Extra/*.m)
AutoApollo2_FRAMEWORKS = CoreServices SafariServices
AutoApollo2_PRIVATE_FRAMEWORKS = FrontBoard FrontBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
