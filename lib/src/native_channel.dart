import 'dart:async';
import '../petrel.dart';

/// 负责Flutter Web和App进行交互
abstract class NativeChannel {
  /// 交互方法名称
  final String name;

  /// 调用方法归属的类名 当存在同名的方法时候可以设置
  final String? className;

  /// 调用的库名
  final String? libraryName;

  Completer<NativeChannelData> _completer = Completer<NativeChannelData>();
  Future<NativeChannelData> get value => _completer.future.then((e) {
        _completer = Completer<NativeChannelData>();
        return e;
      });

  NativeChannel(
    this.name, {
    this.className,
    this.libraryName,
  });

  /// 当前方法返回的信息
  Future onHandlerMessage(ChannelData data);

  void complete(NativeChannelData value) {
    _completer.complete(value);
  }
}
