// ignore: avoid_web_libraries_in_flutter
import 'package:petrel/src/define.dart';
import 'package:petrel/src/native_channel_engine.dart';
import 'package:petrel/src/native_channel_engine_mixin.dart';
import 'package:petrel/src/register_center.dart';

/// 负责注册Flutter Web和App进行交互的引擎
class NativeChannelEngine extends NativeChannelEngineMixin
    implements NativeChannelEnginePlatform {
  @override
  void initEngine({required RegisterCenter registerCenter}) {
    logger.i('register $webCallNativeHandlerName $nativeCallWebName');
    super.initEngine(registerCenter: registerCenter);
  }
}
