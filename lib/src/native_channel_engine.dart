import './io/native_channel_engine_io.dart';
import 'call_message_channel.dart';
import 'message_engine.dart';
import 'revice_message_channel.dart';

abstract class NativeChannelEngine {
  factory NativeChannelEngine() => createChannelEngine();

  register(MessageEngine engine);

  /// 调用通道方法
  /// [channel] 方法的参数
  /// [needReturn] 是否需要返回值
  Future<T?> call<T>(CallMessageChannel channel, [bool needReturn = false]);

  /// 收到回调
  /// [name] 调用的方法名称
  /// [data] 返回的JSON数据
  Future<void> onReviceCallBackMessageHandler(String message);

  /// 接受到通道方法
  /// [name] 调用的方法名称
  /// [data] 返回的JSON数据
  void onReviceMessageHandler(String message);

  /// 添加对于APP调用的监听
  void addListenNativeCall(ReviceMessageChannel channel);

  /// 移除对于APP调用的监听
  void removeListenNativeCall(ReviceMessageChannel channel);
}
