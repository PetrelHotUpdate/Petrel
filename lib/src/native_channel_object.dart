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

class NativeChannelObjectList<T extends NativeChannelObject>
    extends NativeChannelObject {
  final List<T> value;
  NativeChannelObjectList(this.value);

  factory NativeChannelObjectList.fromJson(Map<String, dynamic> json,
      T Function(Map<String, dynamic> json) fromJson) {
    return NativeChannelObjectList<T>(
        json['value'].map((e) => fromJson(e)).toList());
  }

  @override
  Map<String, dynamic> toJson() => {
        'value': value.map((e) => e.toJson()).toList(),
      };
}
