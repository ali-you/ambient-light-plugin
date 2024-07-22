#include "include/ambient_light/ambient_light_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "ambient_light_plugin.h"

void AmbientLightPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ambient_light::AmbientLightPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
