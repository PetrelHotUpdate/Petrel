import './io/native_channel_engine_io.dart';
import 'call_message_channel.dart';
import 'channel_data.dart';
import 'define.dart';
import 'message_engine.dart';
import 'register/petrel_register.dart';
import 'revice_message_channel.dart';

final nativeChannelEngine = NativeChannelEngine();

abstract class NativeChannelEngine {
  factory NativeChannelEngine() => createChannelEngine();

  /// 调用通道方法 如果当前进程注册了通道则直接返回 否则发送消息到其他进程
  /// [channel] 方法的参数
  Future<NativeChannelData> call(CallMessageChannel channel);

  /// 收到调用其他进程回复数据的毁掉
  /// [data] 返回的JSON数据
  Future<void> onReviceCallBackMessageHandler(ChannelData data);

  /// 接受到其他进程发送的消息
  /// [data] 返回的JSON数据
  Future<void> onReviceMessageHandler(ChannelData data);

  /// 添加当前进程通道的监听
  void addListenNativeCall(ReviceMessageChannel channel);

  /// 移除当前进程通道的监听
  void removeListenNativeCall(ReviceMessageChannel channel);

  /// 初始化引擎
  void initEngine({
    required String engineName,
    required MessageEngine messageEngine,
  });

  void addRegister<T extends PetrelRegister>(T register);
  T getRegister<T extends PetrelRegister>();
}
