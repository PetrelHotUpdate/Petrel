import 'channel_data.dart';
import 'native_channel.dart';

/// 主动调用的通道
class CallMessageChannel extends NativeChannel<ChannelData> {
  final String id;
  CallMessageChannel(
    super.name, {
    super.libraryName,
    super.className,
    super.arguments,
    super.timeoutSeconds,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Future onHandlerMessage(ChannelData data) async {
    if (data.id != id) {
      throw 'channel id not match: $id != ${data.id}';
    }
    complete(data.data);
  }
}
