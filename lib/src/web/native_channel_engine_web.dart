import 'dart:developer' as developer;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:petrel/petrel.dart';
import 'package:petrel/src/native_channel_engine_mixin.dart';

NativeChannelEngine createChannelEngine() => NativeChannelEngineWeb();

/// 负责注册Flutter Web和App进行交互的引擎
class NativeChannelEngineWeb extends NativeChannelEngineMixin
    implements NativeChannelEngine {
  @override
  void initEngine(
      {required String engineName, required MessageEngine messageEngine}) {
    developer.log(
      'register $webCallNativeHandlerName $nativeCallWebName',
      name: 'NativeChannelEngineWeb',
    );
    super.initEngine(engineName: engineName, messageEngine: messageEngine);

    /// 注册Web调用App的回调方法
    js.context[webCallNativeHandlerName] = onReviceCallBackMessageHandler;

    /// 注册监听来自APP的调用
    js.context[nativeCallWebName] = onReviceMessageHandler;
  }
}
