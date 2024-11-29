import 'dart:async';
import '../petrel.dart';

/// 负责Flutter Web和App进行交互
abstract class NativeChannel<T> {
  /// 交互方法名称
  final String name;

  /// 调用方法归属的类名 当存在同名的方法时候可以设置
  final String? className;

  /// 调用的参数
  final dynamic arguments;

  /// 接受到方法返回回调
  final ReviceMessageChannelHandler? onHandler;

  final Completer<T?> _completer = Completer<T?>();
  Future<T?> get value => _completer.future;

  NativeChannel(
    this.name, {
    this.onHandler,
    this.className,
    this.arguments,
  });

  /// 当前方法返回的信息
  Future onHandlerMessage(ChannelData data);

  void complete(T? value) {
    _completer.complete(value);
  }
}
