import 'dart:js' as js;
import 'package:petrel/src/native_channel_engine_mixin.dart';
import 'package:petrel/src/web/web_message_engine.dart';
import '../define.dart';
import '../native_channel_engine.dart';

NativeChannelEngine createChannelEngine() => NativeChannelEngineWeb();

/// 负责注册Flutter Web和App进行交互的引擎
class NativeChannelEngineWeb extends NativeChannelEngineMixin
    implements NativeChannelEngine {
  NativeChannelEngineWeb() {
    print('register $webCallNativeHandlerName $nativeCallWebName');
    register(WebMessageEngine());

    /// 注册Web调用App的回调方法
    js.context[webCallNativeHandlerName] = onReviceCallBackMessageHandler;

    /// 注册监听来自APP的调用
    js.context[nativeCallWebName] = onReviceMessageHandler;
  }
}
