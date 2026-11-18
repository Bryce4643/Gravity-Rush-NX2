// Switch 2: the Switch renderer gets Vulkan's entry point from the Mesa driver
// under its ICD name, vk_icdGetInstanceProcAddr. OunceVK, linked statically,
// exports the standard vkGetInstanceProcAddr instead.
// SPDX-License-Identifier: GPL-2.0-or-later

#include <vulkan/vulkan.h>

VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL vk_icdGetInstanceProcAddr(VkInstance instance, const char *name) {
    return vkGetInstanceProcAddr(instance, name);
}
