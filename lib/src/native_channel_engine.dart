import 'package:petrel/petrel.dart';
export './io/native_channel_engine_io.dart'
    if (dart.library.html) './web/native_channel_engine_web.dart';

final nativeChannelEngine = NativeChannelEngine();

abstract class NativeChannelEnginePlatform {
  /// 调用通道方法 如果当前进程注册了通道则直接返回 否则发送消息到其他进程
  /// [channel] 方法的参数
  Future<NativeChannelData> call(CallMessageChannel channel);

  /// 收到调用其他进程回复数据的回调
  /// [data] 返回的JSON数据
  Future<void> onReceiveCallBackMessageHandler(String message);

  /// 接受到其他进程发送的消息
  /// [data] 返回的JSON数据
  Future<void> onReceiveMessageHandler(String message);

  /// 添加当前进程通道的监听
  void addListenNativeCall(ReceiveMessageChannel channel);

  /// 移除当前进程通道的监听
  void removeListenNativeCall(ReceiveMessageChannel channel);

  /// 初始化引擎
  void initEngine({required RegisterCenter registerCenter});
  void initEngineWithMessageEngine({required MessageEngine messageEngine});

  T getRegister<T extends PetrelRegister>();
}
