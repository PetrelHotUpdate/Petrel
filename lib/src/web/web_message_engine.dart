import 'dart:convert';

import 'dart:js' as js;

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
    print('_postMessage method: $method, data: $jsonText');
    js.context[method].callMethod("postMessage", [jsonText]);
  }
}
