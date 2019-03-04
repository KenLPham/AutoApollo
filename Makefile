INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AutoApollo
AutoApollo_FILES = XXXApolloOpener.m
AutoApollo_INSTALL_PATH = /Library/Opener
AutoApollo_EXTRA_FRAMEWORKS = Opener

THEOS_DEVICE_IP = 144.118.101.96

include $(THEOS_MAKE_PATH)/bundle.mk
