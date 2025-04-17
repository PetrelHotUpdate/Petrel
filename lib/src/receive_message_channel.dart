import 'package:petrel/petrel.dart';

/// 等待接受消息的处理通道
class ReceiveMessageChannel extends NativeChannel {
  final ReceiveMessageChannelHandler onReceiveMessageHandler;

  ReceiveMessageChannel(
    super.name, {
    required this.onReceiveMessageHandler,
    super.className,
    super.libraryName,
  });

  @override
  Future onHandlerMessage(ChannelData data) async {
    final value = await onReceiveMessageHandler
        .call(data)
        .then<NativeChannelData>((e) => e)
        .catchError((e) => <String, dynamic>{});
    complete(value);
  }
}
