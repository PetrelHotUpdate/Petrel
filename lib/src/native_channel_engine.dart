import 'dart:async';
import 'dart:convert';

import 'package:petrel/petrel.dart';
import 'package:petrel/src/future_timeout.dart';

final nativeChannelEngine = NativeChannelEngine();

/// 通信引擎
class NativeChannelEngine {
  final List<ReceiveMessageChannel> _receiveMessageChannels = [];
  final RegisterCenter _registerCenter = RegisterCenter();
  MessageEngine _messageEngine = MessageEngine();
  final Map<String, Completer<ChannelData>> _otherProcessChannelCompleters = {};
  RegisterCenter get registerCenter => _registerCenter;
  MessageEngine? get messageEngine => _messageEngine;

  void initEngine({MessageEngine? messageEngine}) {
    initEngineWithMessageEngine(messageEngine ?? _messageEngine);
  }

  void initEngineWithMessageEngine(MessageEngine messageEngine) {
    _messageEngine = messageEngine;
    messageEngine.initMessageEngine();
  }

  Future<ChannelData> call(CallMessageChannel channel) async {
    logger.d(
      '''
[⚪️]call: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.functionName}]
arguments: ${jsonEncode(channel.arguments)}
timeoutSeconds: ${channel.timeoutSeconds}
''',
    );
    final callChannelData = ChannelData(
      channel.functionName,
      id: channel.id,
      data: channel.arguments,
      className: channel.className,
      libraryName: channel.libraryName,
      timeoutSeconds: channel.timeoutSeconds,
    );

    final timeout = Duration(seconds: channel.timeoutSeconds);

    /// 优先从当前进程的注册通道查找 为了解决Flutter web再开发中可能无法调用App通道的方法
    final receiveMessageChannel = getReceiveMessageChannel(callChannelData);
    if (receiveMessageChannel != null) {
      logger.d('''
[🟡]call receive channel: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.functionName}]
arguments: ${jsonEncode(channel.arguments)}
timeoutSeconds: ${channel.timeoutSeconds}
''');

      /// 如果当前进程查找到注册通道则调用返回
      final value = await receiveMessageChannel
          .onReceiveMessageHandler(callChannelData)
          .addTimeout(
        timeout,
        onTimeout: () {
          throw Exception(
              'call [${callChannelData.libraryName}] [${callChannelData.className}] [${callChannelData.functionName}] timeout');
        },
      );
      logger.d('''
[✅]call receive channel value: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.functionName}]
value: $value
''');
      return ChannelData(
        channel.functionName,
        id: channel.id,
        data: value,
        className: channel.className,
        libraryName: channel.libraryName,
        timeoutSeconds: channel.timeoutSeconds,
      );
    } else {
      logger.d('''
[🟡]call other process channel: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.functionName}]
arguments: ${jsonEncode(channel.arguments)}
timeoutSeconds: ${channel.timeoutSeconds}
''');
      final completer = Completer<ChannelData>();
      _otherProcessChannelCompleters[channel.id] = completer;
      _messageEngine.sendMessage(channel);
      final value = await completer.future.addTimeout(timeout, onTimeout: () {
        throw Exception(
            'call ${channel.libraryName} ${channel.className} ${channel.functionName} timeout');
      });
      _otherProcessChannelCompleters.remove(channel.id);
      logger.d('''
[🟢]call other process channel value: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.functionName}]
value: $value
''');
      return value;
    }
  }

  Future<void> onReceiveCallBackMessageHandler(String message) async {
    logger.d('''
[🟡]onReceiveCallBackMessageHandler: $message
''');
    final data = ChannelData.fromJson(jsonDecode(message));
    final completer = _otherProcessChannelCompleters[data.id];
    if (completer == null) {
      throw 'channel completer not found: (${data.id}) [${data.libraryName}] [${data.className}] [${data.functionName}]';
    }
    completer.complete(data);
  }

  Future<void> onReceiveMessageHandler(String message) async {
    final data = ChannelData.fromJson(jsonDecode(message));
    final channelData = await readReceiveData(data);
    _messageEngine.responseMessage(channelData);
  }

  Future<ChannelData> readReceiveData(ChannelData data,
      {Duration timeout = const Duration(seconds: 60)}) async {
    logger.d(
      '[🟢]readReceiveData: ${jsonEncode(data.toJson())}',
    );
    final channel = getReceiveMessageChannel(data);
    if (channel == null) {
      throw 'channel not found: (${data.id}) [${data.libraryName}] [${data.className}] [${data.functionName}]';
    }
    await channel.onReceiveMessageHandler(data);
    final value = await channel
        .onReceiveMessageHandler(data)
        .addTimeout(timeout, onTimeout: () {
      throw Exception('call ${data.functionName}(${data.id}) timeout');
    });
    return ChannelData(
      data.functionName,
      id: data.id,
      data: value,
      className: data.className,
      libraryName: data.libraryName,
      timeoutSeconds: data.timeoutSeconds,
    );
  }

  ReceiveMessageChannel? getReceiveMessageChannel(ChannelData data) {
    final channels = _receiveMessageChannels.where(
      (element) {
        return element.libraryName == data.libraryName &&
            element.className == data.className &&
            element.functionName == data.functionName;
      },
    ).toList();
    return channels.lastOrNull;
  }

  void addReceiveMessageChannel(ReceiveMessageChannel channel) {
    _receiveMessageChannels.add(channel);
  }

  T getRegister<T extends PetrelRegister>() {
    final register = registerCenter.registers.whereType<T>().lastOrNull;
    if (register == null) {
      throw '请先通过addRegister进行注册:${T.toString()}';
    }
    return register;
  }
}
