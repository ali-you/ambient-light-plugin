import Cocoa
import FlutterMacOS
import IOKit

public class AmbientLightPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var timer: Timer?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ambient_light.aliyou.dev", binaryMessenger: registrar.messenger)
        let eventChannel = FlutterEventChannel(name: "ambient_light_stream.aliyou.dev", binaryMessenger: registrar.messenger)

        let instance = AmbientLightPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getAmbientLight":
            getAmbientLight(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getAmbientLight(result: @escaping FlutterResult) {
        guard let sensorValue = readAmbientLightSensor() else {
            result(FlutterError(code: "NO_SENSOR", message: "No ambient light sensor available", details: nil))
            return
        }
        result(sensorValue)
    }

    private func readAmbientLightSensor() -> Float? {
        let matchingDict = IOServiceMatching("AppleLMUController")
        var iterator: io_iterator_t = 0
        let kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iterator)

        if kernResult != KERN_SUCCESS {
            return nil
        }

        var sensorValue: Float = 0.0
        var service: io_object_t = IOIteratorNext(iterator)
        while service != 0 {
            if let data = IORegistryEntryCreateCFProperty(service, "LUMINANCE" as CFString, kCFAllocatorDefault, 0) {
                let luminance = data.takeUnretainedValue() as! CFData
                let value = CFDataGetBytePtr(luminance).withMemoryRebound(to: UInt16.self, capacity: 1) { $0 }
                sensorValue = Float(value.pointee) / 100.0
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)
        return sensorValue
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startListeningForAmbientLightChanges()
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        stopListeningForAmbientLightChanges()
        return nil
    }

    private func startListeningForAmbientLightChanges() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard let eventSink = self.eventSink else {
                timer.invalidate()
                return
            }
            if let sensorValue = self.readAmbientLightSensor() {
                eventSink(sensorValue)
            } else {
                eventSink(FlutterError(code: "NO_SENSOR", message: "No ambient light sensor available", details: nil))
            }
        }
    }

    private func stopListeningForAmbientLightChanges() {
        timer?.invalidate()
        timer = nil
    }
}
