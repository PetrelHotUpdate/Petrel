import 'channel_data.dart';
import 'define.dart';
import 'native_channel.dart';

/// 等待接受消息的处理通道
class ReviceMessageChannel extends NativeChannel {
  final ReviceMessageChannelHandler onReviceMessageHandler;

  ReviceMessageChannel(
    super.name, {
    required this.onReviceMessageHandler,
    super.className,
    super.libraryName,
  });

  @override
  Future onHandlerMessage(ChannelData data) async {
    final value = await onReviceMessageHandler
        .call(data)
        .then<NativeChannelData>((e) => e)
        .catchError((e) => <String, dynamic>{});
    complete(value);
  }
}
