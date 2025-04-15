abstract class NativeChannelObject {
  Map<String, dynamic> toJson();
}

class DefaultNativeChannelObject<T> extends NativeChannelObject {
  final T value;
  DefaultNativeChannelObject(this.value);

  factory DefaultNativeChannelObject.fromJson(Map<String, dynamic> json) {
    return DefaultNativeChannelObject<T>(json['value']);
  }

  @override
  Map<String, dynamic> toJson() => {'value': value};
}
