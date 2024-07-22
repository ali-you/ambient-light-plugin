#ifndef FLUTTER_PLUGIN_AMBIENT_LIGHT_PLUGIN_H_
#define FLUTTER_PLUGIN_AMBIENT_LIGHT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace ambient_light {

class AmbientLightPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AmbientLightPlugin();

  virtual ~AmbientLightPlugin();

  // Disallow copy and assign.
  AmbientLightPlugin(const AmbientLightPlugin&) = delete;
  AmbientLightPlugin& operator=(const AmbientLightPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace ambient_light

#endif  // FLUTTER_PLUGIN_AMBIENT_LIGHT_PLUGIN_H_
