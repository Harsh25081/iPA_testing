import UIKit
import Flutter
import HaishinKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let channel = FlutterMethodChannel(
            name: "flutter.native/rtmp",
            binaryMessenger: controller.binaryMessenger
        )

        rtmpStream = RTMPStream(connection: rtmpConnection)

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            switch call.method {

            case "startStream":

                guard let args = call.arguments as? [String: Any],
                      let url = args["url"] as? String,
                      let key = args["key"] as? String else {

                    result(
                        FlutterError(
                            code: "INVALID_ARGS",
                            message: "Missing URL/Key",
                            details: nil
                        )
                    )
                    return
                }

                self.setupAudio()

                self.rtmpStream?.attachAudio(
                    AVCaptureDevice.default(for: .audio)
                )

                self.rtmpStream?.attachCamera(
                    AVCaptureDevice.default(
                        .builtInWideAngleCamera,
                        for: .video,
                        position: .back
                    )
                )

                self.rtmpConnection.connect(url)
                self.rtmpStream?.publish(key)

                result("Streaming Started")

            case "stopStream":

                self.rtmpStream?.close()
                self.rtmpConnection.close()

                result("Streaming Stopped")

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    private func setupAudio() {

        let session = AVAudioSession.sharedInstance()

        do {

            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [
                    .defaultToSpeaker,
                    .allowBluetooth
                ]
            )

            try session.setActive(true)

        } catch {
            print("Audio Session Error: \(error)")
        }
    }
}

// import UIKit
// import Flutter
// import HaishinKit
// import AVFoundation

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//     private var rtmpConnection = RTMPConnection()
//     private var rtmpStream: RTMPStream!

//     override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//         let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
//         let streamChannel = FlutterMethodChannel(name: "com.example.stream/rtmp", binaryMessenger: controller.binaryMessenger)

//         rtmpStream = RTMPStream(connection: rtmpConnection)
//         // Attach hardware to the stream
//         rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio))
//         rtmpStream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back))

//         streamChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//             if call.method == "startStream" {
//                 let args = call.arguments as! [String: Any]
//                 let url = args["url"] as! String
//                 let name = args["name"] as! String
                
//                 self.rtmpConnection.connect(url)
//                 self.rtmpStream.publish(name)
//                 result(nil)
//             } else if call.method == "stopStream" {
//                 self.rtmpStream.close()
//                 self.rtmpConnection.close()
//                 result(nil)
//             }
//         })

//         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }
// }


// // import Flutter
// // import UIKit

// // @main
// // @objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
// //   override func application(
// //     _ application: UIApplication,
// //     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
// //   ) -> Bool {
// //     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
// //   }

// //   func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
// //     GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
// //   }
// // }
