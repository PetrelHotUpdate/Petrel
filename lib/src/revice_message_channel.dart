import 'channel_data.dart';
import 'define.dart';
import 'native_channel.dart';

/// 等待接受消息的处理通道
class ReviceMessageChannel<T> extends NativeChannel<T> {
  final bool isWeb;
  final ReviceMessageChannelHandler<T> onReviceMessageHandler;

  ReviceMessageChannel(
    super.name, {
    required this.onReviceMessageHandler,
    super.className,
    super.libraryName,
    this.isWeb = false,
  });

  @override
  Future onHandlerMessage(ChannelData data) async {
    final value = await onReviceMessageHandler
        .call(data)
        .then<T?>((e) => e)
        .catchError((e) => null);
    complete(value);
  }
}
