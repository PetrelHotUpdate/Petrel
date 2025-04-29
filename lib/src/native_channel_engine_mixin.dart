import 'dart:convert';

import 'package:petrel/petrel.dart';
import 'package:petrel/src/future_timeout.dart';

abstract class NativeChannelEngineMixin implements NativeChannelEnginePlatform {
  List<ReceiveMessageChannel> ReceiveMessageChannels = [];
  final List<CallMessageChannel> _callMessageChannels = [];
  MessageEngine? _messageEngine;
  RegisterCenter? _registerCenter;
  RegisterCenter get registerCenter {
    if (_registerCenter == null) throw '请先调用initEngine方法';
    return _registerCenter!;
  }

  MessageEngine? get messageEngine {
    if (_messageEngine == null) throw '请先调用initEngineWithMessageEngine方法';
    return _messageEngine!;
  }

  void initEngine({required RegisterCenter registerCenter}) {
    _registerCenter = registerCenter;
    logger.d('正在初始化计划默认的消息引擎');
    initEngineWithMessageEngine(messageEngine: MessageEngine());
  }

  void initEngineWithMessageEngine({required MessageEngine messageEngine}) {
    _messageEngine = messageEngine;
    messageEngine.initMessageEngine();
  }

  @override
  Future<NativeChannelData> call(CallMessageChannel channel) async {
    logger.d(
      '''
[⚪️]call: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.name}]
arguments: ${jsonEncode(channel.arguments)}
timeoutSeconds: ${channel.timeoutSeconds}
''',
    );
    final callChannelData = ChannelData(
      channel.name,
      id: channel.id,
      data: channel.arguments,
      className: channel.className,
      libraryName: channel.libraryName,
      timeoutSeconds: channel.timeoutSeconds,
    );

    final timeout = Duration(seconds: channel.timeoutSeconds);

    /// 优先从当前进程的注册通道查找 为了解决Flutter web再开发中可能无法调用App通道的方法
    final ReceiveMessageChannel = getReceiveMessageChannel(callChannelData);
    if (ReceiveMessageChannel != null) {
      logger.d('''
[🟡]call receive channel: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.name}]
arguments: ${jsonEncode(channel.arguments)}
timeoutSeconds: ${channel.timeoutSeconds}
''');

      /// 如果当前进程查找到注册通道则调用返回
      await ReceiveMessageChannel.onHandlerMessage(callChannelData);
      final value = await ReceiveMessageChannel.value.addTimeout(
        timeout,
        onTimeout: () {
          throw Exception('call ${channel.name}(${channel.id}) timeout');
        },
      );
      logger.d('''
[✅]call receive channel value: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.name}]
arguments: ${jsonEncode(channel.arguments)}
timeoutSeconds: ${channel.timeoutSeconds}
value: $value
''');
      return value;
    } else {
      logger.d('''
[🟡]call other process channel: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.name}]
arguments: ${jsonEncode(channel.arguments)}
timeoutSeconds: ${channel.timeoutSeconds}
''');
      if (_messageEngine == null) throw '请先调用register方法';
      _callMessageChannels.add(channel);
      _messageEngine!.sendMessage(channel);
      final value = await channel.value.addTimeout(timeout, onTimeout: () {
        throw Exception('call ${channel.name}(${channel.id}) timeout');
      });
      _callMessageChannels.remove(channel);
      logger.d('''
[🟢]call other process channel value: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.name}]
arguments: ${jsonEncode(channel.arguments)}
timeoutSeconds: ${channel.timeoutSeconds}
value: $value
''');
      return value;
    }
  }

  @override
  Future<void> onReceiveCallBackMessageHandler(String message) async {
    logger.d('''
[🟡]onReceiveCallBackMessageHandler: $message
''');
    final data = ChannelData.fromJson(jsonDecode(message));
    final channels = _callMessageChannels
        .where((element) =>
            element.id == data.id &&
            element.name == data.name &&
            element.libraryName == data.libraryName &&
            element.className == data.className)
        .toList();
    if (channels.isEmpty) {
      throw 'channel not found: (${data.id}) [${data.libraryName}] [${data.className}] [${data.name}]';
    }
    final channel = channels.last;
    await channel.onHandlerMessage(data);
  }

  @override
  Future<void> onReceiveMessageHandler(String message) async {
    final data = ChannelData.fromJson(jsonDecode(message));
    final channelData = await readReceiveData(data);
    if (_messageEngine == null) throw '请先调用register方法';
    _messageEngine!.responseMessage(ChannelData(
      data.name,
      id: data.id,
      className: data.className,
      libraryName: data.libraryName,
      data: channelData,
      timeoutSeconds: data.timeoutSeconds,
    ));
  }

  Future<NativeChannelData> readReceiveData(ChannelData data,
      {Duration timeout = const Duration(seconds: 60)}) async {
    logger.d(
      '[🟢]readReceiveData: ${jsonEncode(data.toJson())}',
    );
    final channel = getReceiveMessageChannel(data);
    if (channel == null) {
      throw 'channel not found: (${data.id}) [${data.libraryName}] [${data.className}] [${data.name}]';
    }
    await channel.onHandlerMessage(data);
    NativeChannelData value =
        await channel.value.addTimeout(timeout, onTimeout: () {
      throw Exception('call ${data.name}(${data.id}) timeout');
    });
    return value;
  }

  ReceiveMessageChannel? getReceiveMessageChannel(ChannelData data) {
    final channels = ReceiveMessageChannels.where(
      (element) =>
          element.name == data.name &&
          element.className == data.className &&
          element.libraryName == data.libraryName,
    ).toList();
    return channels.lastOrNull;
  }

  @override
  void addListenNativeCall(ReceiveMessageChannel channel) {
    ReceiveMessageChannels.add(channel);
  }

  @override
  void removeListenNativeCall(ReceiveMessageChannel channel) {
    ReceiveMessageChannels.removeWhere((element) =>
        element.name == channel.name &&
        element.className == channel.className &&
        element.libraryName == channel.libraryName);
  }

  @override
  T getRegister<T extends PetrelRegister>() {
    final register = registerCenter.registers.whereType<T>().firstOrNull;
    if (register == null) {
      throw '请先通过addRegister进行注册:${T.toString()}';
    }
    return register;
  }
}
