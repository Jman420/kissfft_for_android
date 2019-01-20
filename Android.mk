LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

include $(LOCAL_PATH)/jni/Android.mk
include $(LOCAL_PATH)/jni/tools/Android.mk

LOCAL_MODULE := kissfft
LOCAL_C_INCLUDES :=  $(LOCAL_PATH)/ $(LOCAL_PATH)/jni $(LOCAL_PATH)/jni/tools
LOCAL_CFLAGS += -x c++

include $(BUILD_SHARED_LIBRARY)

