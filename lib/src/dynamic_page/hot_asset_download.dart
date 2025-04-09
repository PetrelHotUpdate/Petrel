import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:archive/archive.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

class HotAssetDownload {
  /// 允许的热更的路由名称数组
  final List<String> hotRouteNames;

  /// 当前版本号
  final String version;

  /// 热更的环境
  final HotAssetEnvironment environment;

  /// 热更Appwrite的配置
  final HotAssetAppwrite appwrite;

  /// 支持热更的路由
  final List<String> _allowHotRouteNames = [];

  HotAssetDownload({
    required this.hotRouteNames,
    required this.version,
    required this.environment,
    required this.appwrite,
  });

  download() async {
    final client = Client(endPoint: appwrite.endPoint)
      ..setProject(appwrite.projectId);
    final functions = Functions(client);
    final storage = Storage(client);

    /// 查询热更版本信息表
    final responseBody = await functions
        .createExecution(
      functionId: appwrite.functionId,
      body: jsonEncode({
        'buildName': version,
        'routeNames': hotRouteNames,
        'environment': environment.name,
      }),
    )
        .then((e) {
      return e.responseBody;
    }).catchError((e) {
      developer.log(e.toString(), name: 'HotAssetDownload');
      throw Exception('热更版本信息表查询失败');
    });
    final responseJson = JSON(responseBody);
    final code = responseJson['code'].int;
    if (code != 200) {
      throw Exception('热更版本信息表查询失败');
    }
    final result = responseJson['result'].mapValue;
    for (final routeName in result.keys) {
      final routeResult = result[routeName];
      List resourceInfos = routeResult['resourceInfos'];
      await _downloadHotResource(
        routeName,
        resourceInfos,
        storage,
        appwrite.bucketId,
      ).catchError((e) {
        developer.log(e.toString(), name: 'HotAssetDownload');
      });
    }
  }

  /// 下载对应路由的热更资源
  Future<void> _downloadHotResource(
    String routeName,
    List resourceInfos,
    Storage storage,
    String bucketId,
  ) async {
    developer.log('下载资源 $routeName', name: 'HotAssetDownload');
    final hotAssetDir = await hotAssetDirFromRoute(routeName);
    if (await hotAssetDir.exists()) {
      await hotAssetDir.delete(recursive: true);
    }
    final zipsDir = await _hotAssetZipDir();
    for (final resourceInfo in resourceInfos) {
      final fileId = resourceInfo['fileId'];
      final md5 = resourceInfo['md5'];
      final size = resourceInfo['size'];
      final path = resourceInfo['path'];
      final zipFile = File(join(zipsDir.path, '$md5.zip'));
      if (!await zipFile.exists() || await zipFile.length() != size) {
        developer.log('下载资源 $path', name: 'HotAssetDownload');
        final bytes =
            await storage.getFileDownload(bucketId: bucketId, fileId: fileId);
        if (!await zipFile.exists()) {
          await zipFile.create(recursive: true);
        }
        await zipFile.writeAsBytes(bytes);
        developer.log('下载资源 $path 完成', name: 'HotAssetDownload');
      }

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      if (archive.files.isEmpty) {
        throw Exception('ZIP文件解压失败 压缩包内容为空');
      }
      final entry = archive.files.first;
      if (!entry.isFile) {
        throw Exception('ZIP文件解压失败 压缩包内容为目录');
      }
      final filePath =
          join(hotAssetDir.path, joinAll(split(path)..removeAt(0)));
      final file = File(filePath);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsBytes(entry.content as List<int>);
    }
    _allowHotRouteNames.add(routeName);
    developer.log('下载资源 $routeName 完成', name: 'HotAssetDownload');
  }

  /// ZIP资源下载的路径
  Future<Directory> _hotAssetZipDir() => _hotAssetRootDir().then(
        (e) => Directory(join(e.path, 'zips')),
      );

  /// 路由热更保存文件目录
  Future<Directory> hotAssetDirFromRoute(String routeName) =>
      _hotAssetRootDir().then(
        (e) => Directory(join(e.path, 'pages', routeName)),
      );

  /// 热更资源的总目录
  Future<Directory> _hotAssetRootDir() => getApplicationDocumentsDirectory()
      .then((e) => Directory(join(e.path, 'hot_assets')));
}

enum HotAssetEnvironment { adhoc, store }

class HotAssetAppwrite {
  final String endPoint;
  final String projectId;
  final String functionId;
  final String bucketId;

  const HotAssetAppwrite({
    required this.endPoint,
    required this.projectId,
    required this.functionId,
    required this.bucketId,
  });
}
