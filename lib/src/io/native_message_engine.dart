import '../call_message_channel.dart';
import '../channel_data.dart';
import '../define.dart';
import '../message_engine.dart';
import 'web_view_engine.dart';

class NativeMessageEngine extends MessageEngine {
  final WebViewEngine webViewEngine;
  NativeMessageEngine({required this.webViewEngine});
  @override
  Future<void> sendMessage(CallMessageChannel message) async {
    final channelData = ChannelData(
      message.name,
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
