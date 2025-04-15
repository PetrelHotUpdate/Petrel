library petrel;

export 'src/channel_data.dart';
export './src/define.dart';
export './src/native_channel.dart';
export 'src/call_message_channel.dart';
export 'src/revice_message_channel.dart';
export 'src/io/native_channel_engine_io.dart'
    if (dart.library.html) './src/web/engine_for_web.dart'
    if (dart.library.io) './src/io/engine_for_native.dart';
export './src/io/web_view_engine.dart';
export './src/register/petrel_register.dart';
export './src/native_channel_engine.dart';
export './src/native_channel_object.dart';
