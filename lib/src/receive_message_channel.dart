import 'package:petrel/petrel.dart';

/// 等待接受消息的处理通道
class ReceiveMessageChannel {
  final String? libraryName;
  final String? className;
  final String functionName;
  final ReceiveMessageChannelHandler onReceiveMessageHandler;

  ReceiveMessageChannel({
    required this.functionName,
    required this.onReceiveMessageHandler,
    this.libraryName,
    this.className,
  });
}
