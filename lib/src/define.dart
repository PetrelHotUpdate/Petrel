import 'dart:convert';
import 'channel_data.dart';
import 'package:logger/logger.dart';

const nativeCallWebName = 'nativeCallWeb';
const nativeCallWebHandlerName = 'nativeCallWebHandler';
const webCallNativeName = 'webCallNative';
const webCallNativeHandlerName = 'webCallNativeHandler';

typedef NativeChannelData = Map<String, dynamic>;
typedef ReceiveMessageChannelHandler = Future<NativeChannelData> Function(
    ChannelData data);
typedef NativeCallWebHandler = void Function(ChannelData data);
typedef WebCallNativeHandler = void Function(ChannelData data);

final logger = Logger(
  filter: ProductionFilter()..level = Level.debug,
  printer: PrettyPrinter(methodCount: 0),
  output: ConsoleOutput(),
);

/// 获取返回Web调用值的js代码
String getWebCallNativeHandlerRunJavaScript(ChannelData data) {
  return _getRunJavaScript(webCallNativeHandlerName, data.toJson());
}

String getNativeCallWebRunJavaScript(ChannelData data) {
  return _getRunJavaScript(nativeCallWebName, data.toJson());
}

String _getRunJavaScript(String methodName, Map data) {
  final message = json.encode(data);
  return "$methodName('$message')";
}
