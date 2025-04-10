import 'dart:convert';

import 'channel_data.dart';

const nativeCallWebName = 'NativeCallWeb';
const nativeCallWebHandlerName = 'NativeCallWebHandler';
const webCallNativeName = 'WebCallNative';
const webCallNativeHandlerName = 'WebCallNativeHandler';

typedef ReviceMessageChannelHandler<T> = Future<T?> Function(ChannelData data);
typedef NativeCallWebHandler = void Function(ChannelData data);
typedef WebCallNativeHandler = void Function(ChannelData data);

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
