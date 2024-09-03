import Flutter
import UIKit
import AVFoundation

public class AmbientLightPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var result: FlutterResult?
    private var eventSink: FlutterEventSink?
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var isListeningForResult = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "ambient_light.aliyou.dev", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "ambient_light_stream.aliyou.dev", binaryMessenger: registrar.messenger())

        let instance = AmbientLightPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getAmbientLight":
            if isListeningForResult {
                result(FlutterError(code: "IN_PROGRESS", message: "Another ambient light request is in progress", details: nil))
            } else {
                self.result = result
                if let args = call.arguments as? [String: Any],
                   let useFrontCamera = args["useFrontCamera"] as? Bool {
                    startListeningForResult(frontCamera: useFrontCamera)
                } else {
                    startListeningForResult()
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startListeningForResult(frontCamera: Bool = false) {
        if captureSession == nil {
            captureSession = AVCaptureSession()
        }

        guard let captureSession = captureSession else {
            result?(FlutterError(code: "NO_SESSION", message: "Could not create capture session", details: nil))
            return
        }

        let position: AVCaptureDevice.Position = frontCamera ? .front : .back

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            result?(FlutterError(code: "NO_DEVICE", message: "No video device available", details: nil))
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
        } catch {
            result?(FlutterError(code: "INPUT_ERROR", message: "Could not create input from device", details: error.localizedDescription))
            return
        }

        videoOutput = AVCaptureVideoDataOutput()
        guard let videoOutput = videoOutput else {
            result?(FlutterError(code: "NO_OUTPUT", message: "Could not create video output", details: nil))
            return
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
        captureSession.addOutput(videoOutput)
        captureSession.startRunning()
    }

    private func startListening(frontCamera: Bool = false) {
        if captureSession == nil {
            captureSession = AVCaptureSession()
        }

        guard let captureSession = captureSession else {
            eventSink?(FlutterError(code: "NO_SESSION", message: "Could not create capture session", details: nil))
            return
        }

        let position: AVCaptureDevice.Position = frontCamera ? .front : .back

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            eventSink?(FlutterError(code: "NO_DEVICE", message: "No video device available", details: nil))
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
        } catch {
            eventSink?(FlutterError(code: "INPUT_ERROR", message: "Could not create input from device", details: error.localizedDescription))
            return
        }

        videoOutput = AVCaptureVideoDataOutput()
        guard let videoOutput = videoOutput else {
            eventSink?(FlutterError(code: "NO_OUTPUT", message: "Could not create video output", details: nil))
            return
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
        captureSession.addOutput(videoOutput)
        captureSession.startRunning()
    }

    private func stopListening() {
        captureSession?.stopRunning()
        captureSession = nil
        videoOutput = nil
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events

        if let args = arguments as? [String: Any],
        let useFrontCamera = args["useFrontCamera"] as? Bool{
            startListening(frontCamera: useFrontCamera)
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopListening()
        self.eventSink = nil
        return nil
    }
}

extension AmbientLightPlugin: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let metadataAttachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate) as? [String: Any],
              let exifMetadata = metadataAttachments[kCGImagePropertyExifDictionary as String] as? [String: Any],
              let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? Double else {
            if let result = result {
                result(FlutterError(code: "NO_METADATA", message: "Could not get brightness from metadata", details: nil))
                self.result = nil
                isListeningForResult = false
                stopListening()
            } else if let eventSink = eventSink {
                eventSink(FlutterError(code: "NO_METADATA", message: "Could not get brightness from metadata", details: nil))
            }
            return
        }

        DispatchQueue.main.async {
            if let result = self.result {
                result(brightnessValue)
                self.result = nil
                self.isListeningForResult = false
                self.stopListening()
            } else if let eventSink = self.eventSink {
                eventSink(brightnessValue)
            }
        }
    }
}
