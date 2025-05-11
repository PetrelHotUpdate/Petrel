import 'define.dart';

/// 主动调用的通道
class CallMessageChannel {
  final String id;
  final String functionName;
  final String? libraryName;
  final String? className;
  final NativeChannelData arguments;
  final int timeoutSeconds;
  CallMessageChannel({
    required this.functionName,
    this.arguments = const {},
    this.timeoutSeconds = 60,
    this.libraryName,
    this.className,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();
}
