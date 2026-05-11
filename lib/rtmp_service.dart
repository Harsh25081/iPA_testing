import 'package:flutter/services.dart';

class RtmpService {
  static const _channel = MethodChannel('flutter.native/rtmp');

  static Future<void> start(String url, String key) async {
    try {
      final result = await _channel.invokeMethod('startStream', {
        'url': url,
        'key': key,
      });
      print(result);
    } on PlatformException catch (e) {
      print("Failed to start stream: ${e.message}");
    }
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stopStream');
  }
}
