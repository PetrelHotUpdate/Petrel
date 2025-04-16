
import 'define.dart';

class ChannelData {
  final String? id;
  final String? className;
  final String? libraryName;
  final String name;
  final int timeoutSeconds;
  final NativeChannelData data;

  const ChannelData(
    this.name, {
    this.id,
    this.className,
    this.libraryName,
    this.data = const {},
    this.timeoutSeconds = 60,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) => ChannelData(
        json['name'],
        id: json['id'],
        className: json['className'],
        libraryName: json['libraryName'],
        data: json['data'],
        timeoutSeconds: json['timeoutSeconds'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'className': className,
        'libraryName': libraryName,
        'data': data,
        'name': name,
        'timeoutSeconds': timeoutSeconds,
      };
}
