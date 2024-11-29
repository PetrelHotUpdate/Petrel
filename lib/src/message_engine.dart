import 'call_message_channel.dart';
import 'channel_data.dart';

abstract class MessageEngine {
  /// 主动发送消息
  void sendMessage(CallMessageChannel message);
  void responseMessage(ChannelData response);
}
