import 'dart:developer' as developer;
import 'package:petrel/src/define.dart';
import 'package:petrel/src/future_timeout.dart';
import 'call_message_channel.dart';
import 'channel_data.dart';
import 'message_engine.dart';
import 'native_channel_engine.dart';
import 'revice_message_channel.dart';

abstract class NativeChannelEngineMixin implements NativeChannelEngine {
  List<ReviceMessageChannel> reviceMessageChannels = [];
  List<CallMessageChannel> callMessageChannels = [];
  MessageEngine? _messageEngine;

  @override
  register(MessageEngine engine) {
    _messageEngine = engine;
  }

  @override
  Future<T> call<T>(CallMessageChannel channel) async {
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
      /// 如果当前进程查找到注册通道则调用返回
      await reviceMessageChannel.onHandlerMessage(callChannelData);
      return await reviceMessageChannel.value.addTimeout(
        timeout,
        onTimeout: () {
          throw Exception('call ${channel.name}(${channel.id}) timeout');
        },
      );
    } else {
      if (_messageEngine == null) throw '请先调用register方法';
      _messageEngine!.sendMessage(channel);
      final value = await channel.value.timeout(timeout, onTimeout: () {
        throw Exception('call ${channel.name}(${channel.id}) timeout');
      });
      developer.log(
        'call ${channel.name}(${channel.id}): $value',
        name: 'NativeChannelEngineMixin',
      );
      return value as T;
    }
  }

  @override
  Future<void> onReviceCallBackMessageHandler(ChannelData data) async {
    developer.log(
      'onReviceCallBackMessageHandler:libraryName ${data.libraryName}, className ${data.className}, name ${data.name}, ${data.data}',
      name: 'NativeChannelEngineMixin',
    );
    final channels = callMessageChannels
        .where((element) =>
            element.id == data.id &&
            element.name == data.name &&
            element.libraryName == data.libraryName &&
            element.className == data.className)
        .toList();
    if (channels.isEmpty) {
      throw 'libraryName:${data.libraryName}, className:${data.className}, name:${data.name} id:${data.id} 没有注册';
    }
    final channel = channels.last;
    await channel.onHandlerMessage(data);
    callMessageChannels.remove(channel);
  }

  @override
  Future<ChannelData> onReviceMessageHandler(ChannelData data) async {
    return await readReviceData(data);
  }

  @override
  Future<ChannelData> readReviceData(ChannelData data,
      {Duration timeout = const Duration(seconds: 60)}) async {
    developer.log(
      'onReviceMessageHandler: ${data.name}, $data',
      name: 'NativeChannelEngineMixin',
    );
    final channels = reviceMessageChannels
        .where((element) =>
            element.name == data.name && element.className == data.className)
        .toList();
    if (channels.isEmpty) {
      throw 'class:${data.className}, name:${data.name} 没有注册';
    }
    final channel = channels.last;
    channel.onHandlerMessage(data);
    return await channel.value.timeout(timeout, onTimeout: () {
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
  void addListenNativeCallWeb(String routeName, NativeCallWebHandler handler) {
    nativeCallWebHandlers[routeName] = handler;
  }

  @override
  void removeListenNativeCallWeb(String routeName) {
    nativeCallWebHandlers.remove(routeName);
  }

  @override
  void addListenWebCallNativeCallBack(
      String routeName, WebCallNativeHandler handler) {
    webCallNativeHandlers[routeName] = handler;
  }

  @override
  void removeListenWebCallNativeCallBack(String routeName) {
    webCallNativeHandlers.remove(routeName);
  }
}
