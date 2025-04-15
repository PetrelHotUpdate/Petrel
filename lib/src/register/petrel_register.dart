import '../call_message_channel.dart';
import '../define.dart';
import '../native_channel_engine.dart';
import '../revice_message_channel.dart';

abstract class PetrelRegister {
  String get libraryName;
  String get className;

  void register(
    String name,
    ReviceMessageChannelHandler onReviceMessageHandler,
  ) {
    nativeChannelEngine.addListenNativeCall(
      ReviceMessageChannel(
        name,
        libraryName: libraryName,
        className: className,
        onReviceMessageHandler: onReviceMessageHandler,
      ),
    );
  }

  Future<NativeChannelData> call(String name, Map<String, dynamic> arguments) {
    return nativeChannelEngine.call(
      CallMessageChannel(
        name,
        libraryName: libraryName,
        className: className,
        arguments: arguments,
      ),
    );
  }
}
