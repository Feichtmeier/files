//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <handy_window/handy_window_plugin.h>
#include <xdg_icons/xdg_icons_plugin.h>
#include <yaru/yaru_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) handy_window_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HandyWindowPlugin");
  handy_window_plugin_register_with_registrar(handy_window_registrar);
  g_autoptr(FlPluginRegistrar) xdg_icons_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "XdgIconsPlugin");
  xdg_icons_plugin_register_with_registrar(xdg_icons_registrar);
  g_autoptr(FlPluginRegistrar) yaru_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "YaruPlugin");
  yaru_plugin_register_with_registrar(yaru_registrar);
}
