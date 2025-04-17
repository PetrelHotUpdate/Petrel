import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:petrel/petrel.dart';

class MessageEngine extends MessageEnginePlatform {
  MessageEngine([WebViewEngine webViewEngine = const DefaultWebViewEngine()])
      : super(webViewEngine);

  @override
  void initMessageEngine() {
    js.context[webCallNativeHandlerName] =
        nativeChannelEngine.onReceiveCallBackMessageHandler;
    js.context[nativeCallWebName] = nativeChannelEngine.onReceiveMessageHandler;
  }

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
        libraryName: message.libraryName,
        data: message.arguments,
        timeoutSeconds: message.timeoutSeconds,
      ).toJson(),
    );
  }

  void _postMessage(String method, Map data) {
    final jsonText = json.encode(data);
    logger.i('_postMessage method: $method, data: $jsonText');
    var target = js.context[method];
    logger.i('target: $target');
    if (target != null) {
      target.callMethod("postMessage", [jsonText]);
    } else {
      logger.e('The object for method $method is null.');
    }
  }
}
