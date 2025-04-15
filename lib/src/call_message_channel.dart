import 'channel_data.dart';
import 'define.dart';
import 'native_channel.dart';

/// 主动调用的通道
class CallMessageChannel extends NativeChannel {
  final String id;
  final NativeChannelData arguments;
  final int timeoutSeconds;
  CallMessageChannel(
    super.name, {
    super.libraryName,
    super.className,
    this.arguments = const {},
    this.timeoutSeconds = 60,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Future onHandlerMessage(ChannelData data) async {
    if (data.id != id) {
      throw 'channel id not match: $id != ${data.id}';
    }
    complete(data.data);
  }
}
