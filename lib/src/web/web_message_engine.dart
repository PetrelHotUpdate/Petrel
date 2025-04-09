import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:developer' as developer;
import 'package:petrel/src/channel_data.dart';

import '../call_message_channel.dart';
import '../define.dart';
import '../message_engine.dart';

class WebMessageEngine extends MessageEngine {
  @override
  void responseMessage(ChannelData response) {
    _postMessage(
      nativeCallWebHandlerName,
      response.toJson(),
    );
  }

  @override
  void sendMessage(CallMessageChannel message) {
    _postMessage(
      webCallNativeName,
      ChannelData(
        message.name,
        id: message.id,
        className: message.className,
        data: message.arguments,
      ).toJson(),
    );
  }

  void _postMessage(String method, Map data) {
    final jsonText = json.encode(data);
    developer.log('_postMessage method: $method, data: $jsonText',
        name: 'WebMessageEngine');
    js.context[method].callMethod("postMessage", [jsonText]);
  }
}
