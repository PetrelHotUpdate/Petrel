import 'package:petrel/petrel.dart';

class NativeMessageEngine extends MessageEngine {
  @override
  Future<void> sendMessage(CallMessageChannel message) async {
    final value = await nativeChannelEngine.readReviceData(ChannelData(
      message.name,
      id: message.id,
      className: message.className,
      libraryName: message.libraryName,
      data: message.arguments,
    ));
    message.complete(value);
  }

  @override
  void responseMessage(ChannelData response) {
    throw UnimplementedError();
  }
}
