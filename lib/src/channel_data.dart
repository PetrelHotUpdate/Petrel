class ChannelData<T> {
  final String? id;
  final String? className;
  final String? libraryName;
  final String name;
  final T? data;

  const ChannelData(
    this.name, {
    this.id,
    this.className,
    this.libraryName,
    this.data,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) => ChannelData(
        json['name'],
        id: json['id'],
        className: json['className'],
        libraryName: json['libraryName'],
        data: json['data'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'className': className,
        'libraryName': libraryName,
        'data': data,
        'name': name,
      };
}
