import 'dart:async';

import 'package:petrel/petrel.dart';

class MessageEngine extends MessageEnginePlatform {
  MessageEngine([WebViewEngine webViewEngine = const DefaultWebViewEngine()])
      : super(webViewEngine);
  @override
  void initMessageEngine() {}
  @override
  Future<void> sendMessage(CallMessageChannel message) async {
    final channelData = ChannelData(
      message.functionName,
      id: message.id,
      className: message.className,
      libraryName: message.libraryName,
      data: message.arguments,
      timeoutSeconds: message.timeoutSeconds,
    );
    final script = getNativeCallWebRunJavaScript(channelData);
    webViewEngine.runJavaScript(script);
  }

  @override
  void responseMessage(ChannelData response) {
    final script = getWebCallNativeHandlerRunJavaScript(response);
    webViewEngine.runJavaScript(script);
  }
}
