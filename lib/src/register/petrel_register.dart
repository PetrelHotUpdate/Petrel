import 'package:petrel/petrel.dart';

abstract class PetrelRegister {
  String get libraryName;
  String get className;

  final List<ReceiveMessageChannel> _receiveMessageChannels = [];

  void register(
    String name,
    ReceiveMessageChannelHandler onReceiveMessageHandler,
  ) {
    final receiveMessageChannel = ReceiveMessageChannel(
      name,
      libraryName: libraryName,
      className: className,
      onReceiveMessageHandler: onReceiveMessageHandler,
    );
    _receiveMessageChannels.add(receiveMessageChannel);
    nativeChannelEngine.addListenNativeCall(receiveMessageChannel);
  }

  void deregister(ReceiveMessageChannelHandler onReceiveMessageHandler) {
    final receiveMessageChannel = _receiveMessageChannels
        .where(
          (element) =>
              element.onReceiveMessageHandler == onReceiveMessageHandler,
        )
        .firstOrNull;
    if (receiveMessageChannel != null) {
      nativeChannelEngine.removeListenNativeCall(receiveMessageChannel);
      _receiveMessageChannels.remove(receiveMessageChannel);
    }
  }

  Future<NativeChannelData> call(String name, Map<String, dynamic> arguments) {
    final callMessageChannel = CallMessageChannel(
      name,
      libraryName: libraryName,
      className: className,
      arguments: arguments,
    );
    return nativeChannelEngine.call(callMessageChannel);
  }
}
