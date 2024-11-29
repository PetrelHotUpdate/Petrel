import 'dart:convert';

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
  Future<T?> call<T>(CallMessageChannel channel,
      [bool needReturn = false]) async {
    if (_messageEngine == null) throw '请先调用register方法';
    _messageEngine!.sendMessage(channel);
    if (!needReturn) return null;
    callMessageChannels.add(channel);
    final value = await channel.value;
    print('call ${channel.name}(${channel.id}): $value');
    return value as T;
  }

  @override
  Future<void> onReviceCallBackMessageHandler(String message) async {
    final ChannelData data = ChannelData.fromJson(json.decode(message));
    print('onWebCallNativeHandler: ${data.name}, $data');
    final channels = callMessageChannels
        .where((element) => element.id == data.id && element.name == data.name)
        .toList();
    for (var channel in channels) {
      await channel.onHandlerMessage(data);
      callMessageChannels.remove(channel);
    }
  }

  @override
  void onReviceMessageHandler(String message) async {
    final ChannelData data = ChannelData.fromJson(json.decode(message));
    print('onNativeCallWeb: ${data.name}, $data');
    final channels = reviceMessageChannels
        .where((element) =>
            element.name == data.name && element.className == data.className)
        .toList();
    for (var channel in channels) {
      channel.onHandlerMessage(data);
      channel.value.then((value) {
        if (_messageEngine == null) throw '请先调用register方法';
        _messageEngine!.responseMessage(
          ChannelData(
            data.name,
            id: data.id,
            data: value,
            className: data.className,
          ),
        );
      });
    }
  }

  @override
  void addListenNativeCall(ReviceMessageChannel channel) {
    reviceMessageChannels.add(channel);
  }

  @override
  void removeListenNativeCall(ReviceMessageChannel channel) {
    reviceMessageChannels.remove(channel);
  }
}
