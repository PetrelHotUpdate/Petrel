import 'package:petrel/petrel.dart';

abstract class PetrelRegister {
  String get libraryName;
  String get className;

  void register<T>(
    String name,
    ReviceMessageChannelHandler<T> onReviceMessageHandler,
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
}
