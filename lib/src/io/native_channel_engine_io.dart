import 'package:petrel/src/native_channel_engine_mixin.dart';
import '../native_channel_engine.dart';

NativeChannelEngine createChannelEngine() => NativeChannelEngineIO();

class NativeChannelEngineIO extends NativeChannelEngineMixin
    implements NativeChannelEngine {
  NativeChannelEngineIO();
}
