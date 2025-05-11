import 'package:petrel/petrel.dart';

abstract class PetrelRegister {
  String get libraryName;
  String get className;

  void register(
    String functionName,
    ReceiveMessageChannelHandler onReceiveMessageHandler,
  ) {
    final receiveMessageChannel = ReceiveMessageChannel(
      functionName: functionName,
      libraryName: libraryName,
      className: className,
      onReceiveMessageHandler: onReceiveMessageHandler,
    );
    nativeChannelEngine.addReceiveMessageChannel(receiveMessageChannel);
  }

  Future<NativeChannelData> call(String name, Map<String, dynamic> arguments) {
    final callMessageChannel = CallMessageChannel(
      functionName: name,
      libraryName: libraryName,
      className: className,
      arguments: arguments,
    );
    return nativeChannelEngine
        .call(callMessageChannel)
        .then((value) => value.data);
  }
}
