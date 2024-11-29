import 'channel_data.dart';
import 'define.dart';
import 'native_channel.dart';

/// 等待接受消息的处理通道
class ReviceMessageChannel<T> extends NativeChannel<T> {
  final ReviceMessageChannelHandler<T> onReviceMessageHandler;

  ReviceMessageChannel(
    super.name, {
    required this.onReviceMessageHandler,
    super.className,
  });

  @override
  Future onHandlerMessage(ChannelData data) async {
    final value = await onReviceMessageHandler.call(data);
    complete(value);
  }
}
