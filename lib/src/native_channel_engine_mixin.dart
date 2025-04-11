import 'dart:convert';
import 'dart:developer' as developer;
import 'package:petrel/src/define.dart';

import 'call_message_channel.dart';
import 'channel_data.dart';
import 'message_engine.dart';
import 'native_channel_engine.dart';
import 'revice_message_channel.dart';

abstract class NativeChannelEngineMixin implements NativeChannelEngine {
  List<ReviceMessageChannel> reviceMessageChannels = [];
  List<CallMessageChannel> callMessageChannels = [];
  Map<String, NativeCallWebHandler> nativeCallWebHandlers = {};
  Map<String, WebCallNativeHandler> webCallNativeHandlers = {};
  MessageEngine? _messageEngine;

  @override
  register(MessageEngine engine) {
    _messageEngine = engine;
  }

  @override
  Future<T?> call<T>(
    CallMessageChannel channel, [
    bool needReturn = false,
    Duration timeout = const Duration(seconds: 60),
  ]) async {
    if (_messageEngine == null) throw '请先调用register方法';
    _messageEngine!.sendMessage(channel);
    if (!needReturn) return null;
    callMessageChannels.add(channel);
    final value = await channel.value.timeout(timeout, onTimeout: () {
      throw Exception('call ${channel.name}(${channel.id}) timeout');
    });
    developer.log(
      'call ${channel.name}(${channel.id}): $value',
      name: 'NativeChannelEngineMixin',
    );
    return value as T;
  }

  @override
  Future<void> onReviceCallBackMessageHandler(String message) async {
    final ChannelData data = ChannelData.fromJson(json.decode(message));
    developer.log(
      'onReviceCallBackMessageHandler: ${data.name}, $data',
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
      throw 'class:${data.className}, name:${data.name} 没有注册';
    }
    final channel = channels.last;
    await channel.onHandlerMessage(data);
    callMessageChannels.remove(channel);
  }

  @override
  Future<ChannelData> onReviceMessageHandler(String message) async {
    final ChannelData data = ChannelData.fromJson(json.decode(message));
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
