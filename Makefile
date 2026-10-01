TARGET = iphone:clang:latest:6.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPodClassic

iPodClassic_FILES = iPodClassiciOS6/main.m \
                    iPodClassiciOS6/AppDelegate.m \
                    iPodClassiciOS6/ViewController.m \
                    iPodClassiciOS6/ClickWheelView.m \
                    iPodClassiciOS6/iPodDisplayView.m \
                    iPodClassiciOS6/MusicLibraryManager.m

iPodClassic_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AVFoundation MediaPlayer AudioToolbox
iPodClassic_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk
