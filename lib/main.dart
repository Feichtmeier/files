import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';

const start = '/home/frederik';
const home = start;

const favPathMap = <String, String>{
  'Home': home,
  'Pictures': '$home/Bilder/',
  'Documents': '$home/Dokumente/',
  'Music': '$home/Musik/'
};

void main() {
  runApp(const FilesApp());
}

class FilesApp extends StatelessWidget {
  const FilesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const _App(),
        );
      },
    );
  }
}

class _App extends StatelessWidget {
  const _App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YaruMasterDetailPage(
      appBar: AppBar(
        title: const Text('Files'),
      ),
      pageBuilder: (context, index) {
        final favEntry = favPathMap.entries.elementAt(index);

        return Navigator(
          pages: [
            MaterialPage(
              child: PathPage(
                path: favEntry.value,
                includeBackButton: false,
              ),
            )
          ],
          onPopPage: (route, result) => route.didPop(result),
        );
      },
      tileBuilder: (context, index, selected) {
        var e = favPathMap.entries.elementAt(index);
        return Tooltip(
          message: e.value,
          child: YaruMasterTile(
            leading: const Icon(YaruIcons.folder),
            title: Text(e.key),
          ),
        );
      },
      leftPaneWidth: 200,
      length: favPathMap.length,
    );
  }
}

class PathGrid extends StatelessWidget {
  const PathGrid({
    Key? key,
    required this.path,
  }) : super(key: key);

  final String path;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: getFiles(path: path),
      builder: ((context, snapshot) => snapshot.hasData
          ? GridView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final e = snapshot.data!.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Tooltip(
                    message: e.path.replaceAll(path, '').replaceAll('/', ''),
                    child: Material(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          if (isDir(e)) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return PathPage(
                                    path: e.absolute.path,
                                  );
                                },
                              ),
                            );
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              e.path.endsWith('.png') ||
                                      e.path.endsWith('.jpg') ||
                                      e.path.endsWith('.webp') ||
                                      e.path.endsWith('.jpeg')
                                  ? YaruIcons.image_filled
                                  : e.path.endsWith('.mp3')
                                      ? YaruIcons.audio
                                      : isDir(e)
                                          ? YaruIcons.folder
                                          : YaruIcons.document,
                              size: 70,
                              color: yaruLight.colorScheme.primary,
                            ),
                            Text(
                              e.path.replaceAll(path, '').replaceAll('/', ''),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
              ),
            )
          : const Center(child: YaruCircularProgressIndicator())),
    );
  }
}

class PathPage extends StatelessWidget {
  const PathPage({
    Key? key,
    required this.path,
    this.includeBackButton = true,
  }) : super(key: key);

  final String path;
  final bool includeBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: includeBackButton ? const YaruBackButton() : null,
        title: Text(path),
      ),
      body: PathGrid(
        path: path,
      ),
    );
  }
}

Future<List<FileSystemEntity>> getFiles({required String path}) async {
  return await Directory(path).list().toList();
}

bool isDir(FileSystemEntity e) {
  return FileSystemEntity.typeSync(e.path) != FileSystemEntityType.notFound;
}

class PageItem {
  const PageItem({
    required this.titleBuilder,
    required this.builder,
    required this.iconBuilder,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder builder;
  final Widget Function(BuildContext context, bool selected) iconBuilder;
}
