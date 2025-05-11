import 'dart:async';

import 'call_message_channel.dart';
import 'channel_data.dart';
import 'io/web_view_engine.dart';
export 'io/native_message_engine.dart'
    if (dart.library.html) 'web/web_message_engine.dart';

abstract class MessageEnginePlatform {
  final WebViewEngine webViewEngine;
  MessageEnginePlatform([this.webViewEngine = const DefaultWebViewEngine()]);

  void initMessageEngine();

  /// 主动发送消息
  void sendMessage(CallMessageChannel message);
  void responseMessage(ChannelData response);
}
