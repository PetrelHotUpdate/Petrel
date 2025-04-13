library petrel;

export 'src/channel_data.dart';
export './src/define.dart';
export './src/native_channel.dart';
export 'src/call_message_channel.dart';
export 'src/revice_message_channel.dart';
export 'src/native_channel_engine.dart'
    if (dart.library.html) './src/web/native_channel_engine_web.dart'
    if (dart.library.io) './src/io/native_channel_engine_io.dart'
    show NativeChannelEngine, nativeChannelEngine;
export './src/message_engine.dart'
    if (dart.library.html) './src/web/web_message_engine.dart'
    if (dart.library.io) './src/io/native_message_engine.dart';
export './src/io/web_view_engine.dart';
export './src/register/petrel_register.dart';
