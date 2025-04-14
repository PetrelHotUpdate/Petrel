import 'dart:developer' as developer;
import 'package:petrel/src/future_timeout.dart';

import 'call_message_channel.dart';
import 'channel_data.dart';
import 'message_engine.dart';
import 'native_channel_engine.dart';
import 'register/petrel_register.dart';
import 'revice_message_channel.dart';

abstract class NativeChannelEngineMixin implements NativeChannelEngine {
  List<ReviceMessageChannel> reviceMessageChannels = [];
  final List<CallMessageChannel> _callMessageChannels = [];
  String? _engineName;
  MessageEngine? _messageEngine;
  List<PetrelRegister> _petrelRegisters = [];
  MessageEngine get messageEngine {
    if (_messageEngine == null) throw '请先调用initEngine方法';
    return _messageEngine!;
  }

  String get engineName {
    if (_engineName == null) throw '请先调用initEngine方法';
    return _engineName!;
  }

  @override
  void initEngine({
    required String engineName,
    required MessageEngine messageEngine,
  }) {
    _engineName = engineName;
    _messageEngine = messageEngine;
  }

  @override
  Future<T> call<T>(CallMessageChannel channel) async {
    developer.log(
      'call: (${channel.id}) [${channel.libraryName}] [${channel.className}] [${channel.name}]',
      name: 'NativeChannelEngineMixin',
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
    final reviceMessageChannel = getReviceMessageChannel(callChannelData);
    if (reviceMessageChannel != null) {
      developer.log(
        'call: (${channel.id}) native revice channel',
        name: 'NativeChannelEngineMixin',
      );

      /// 如果当前进程查找到注册通道则调用返回
      await reviceMessageChannel.onHandlerMessage(callChannelData);
      final value = await reviceMessageChannel.value.addTimeout(
        timeout,
        onTimeout: () {
          throw Exception('call ${channel.name}(${channel.id}) timeout');
        },
      );
      developer.log(
        'call: (${channel.id}) native revice channel value $value',
        name: 'NativeChannelEngineMixin',
      );
      return value as T;
    } else {
      developer.log(
        'call: (${channel.id}) other process channel',
        name: 'NativeChannelEngineMixin',
      );
      if (_messageEngine == null) throw '请先调用register方法';
      _callMessageChannels.add(channel);
      _messageEngine!.sendMessage(channel);
      final value = await channel.value.addTimeout(timeout, onTimeout: () {
        throw Exception('call ${channel.name}(${channel.id}) timeout');
      });
      _callMessageChannels.remove(channel);
      developer.log(
        'call (${channel.id}) other process channel value $value',
        name: 'NativeChannelEngineMixin',
      );
      return value as T;
    }
  }

  @override
  Future<void> onReviceCallBackMessageHandler(ChannelData data) async {
    developer.log(
      'onReviceCallBackMessageHandler:(${data.id}) [${data.libraryName}] [${data.className}] [${data.name}]',
      name: 'NativeChannelEngineMixin',
    );
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
  Future<void> onReviceMessageHandler(ChannelData data) async {
    final channelData = await readReviceData(data);
    if (_messageEngine == null) throw '请先调用register方法';
    _messageEngine!.responseMessage(channelData);
  }

  Future<ChannelData> readReviceData(ChannelData data,
      {Duration timeout = const Duration(seconds: 60)}) async {
    developer.log(
      'readReviceData: (${data.id}) [${data.libraryName}] [${data.className}] [${data.name}]',
      name: 'NativeChannelEngineMixin',
    );
    final channel = getReviceMessageChannel(data);
    if (channel == null) {
      throw 'channel not found: (${data.id}) [${data.libraryName}] [${data.className}] [${data.name}]';
    }
    await channel.onHandlerMessage(data);
    return await channel.value.addTimeout(timeout, onTimeout: () {
      throw Exception('call ${data.name}(${data.id}) timeout');
    });
  }

  ReviceMessageChannel? getReviceMessageChannel(ChannelData data) {
    final channels = reviceMessageChannels
        .where(
          (element) =>
              element.name == data.name &&
              element.className == data.className &&
              element.libraryName == data.libraryName,
        )
        .toList();
    return channels.lastOrNull;
  }

  @override
  void addListenNativeCall(ReviceMessageChannel channel) {
    reviceMessageChannels.add(channel);
  }

  @override
  void removeListenNativeCall(ReviceMessageChannel channel) {
    reviceMessageChannels.removeWhere((element) =>
        element.name == channel.name &&
        element.className == channel.className &&
        element.libraryName == channel.libraryName);
  }

  @override
  void addRegister<T extends PetrelRegister>(T register) {
    final oldRegister = _petrelRegisters.whereType<T>().firstOrNull;
    if (oldRegister != null) {
      throw 'register already exists: ${oldRegister.libraryName} ${oldRegister.className}';
    }
    _petrelRegisters.add(register);
  }

  @override
  T getRegister<T extends PetrelRegister>() {
    final register = _petrelRegisters.whereType<T>().firstOrNull;
    if (register == null) {
      throw '请先通过addRegister进行注册';
    }
    return register;
  }
}
