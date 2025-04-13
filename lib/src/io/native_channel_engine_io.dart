import 'package:petrel/petrel.dart';
import 'package:petrel/src/native_channel_engine_mixin.dart';

NativeChannelEngine createChannelEngine() => NativeChannelEngineIO();

class NativeChannelEngineIO extends NativeChannelEngineMixin
    implements NativeChannelEngine {}
