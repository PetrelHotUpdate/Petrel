import 'define.dart';

class ChannelData {
  final String? id;
  final String? libraryName;
  final String? className;
  final String functionName;
  final int timeoutSeconds;
  final NativeChannelData data;

  const ChannelData(
    this.functionName, {
    this.id,
    this.className,
    this.libraryName,
    this.data = const {},
    this.timeoutSeconds = 60,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) => ChannelData(
        json['functionName'],
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
        'functionName': functionName,
        'timeoutSeconds': timeoutSeconds,
      };
}
