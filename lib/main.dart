import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';

const start = '/home/frederik';
const home = start;

const favPathMap = <String, String>{
  'Home': home,
  'Pictures': '$home/Bilder/',
  'Documents': '$home/Dokumente/',
  'Music': '$home/Musik/',
};

Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();
  runApp(const FilesApp());
}

class FilesApp extends StatelessWidget {
  const FilesApp({super.key});

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
  const _App();

  @override
  Widget build(BuildContext context) {
    return YaruMasterDetailPage(
      appBar: const YaruWindowTitleBar(
        title: Text('Files'),
      ),
      pageBuilder: (context, index) {
        final favEntry = favPathMap.entries.elementAt(index);

        return PathPage(
          path: favEntry.value,
          includeBackButton: false,
        );
      },
      tileBuilder: (context, index, selected, availableWidth) {
        var e = favPathMap.entries.elementAt(index);
        return Tooltip(
          message: e.value,
          child: YaruMasterTile(
            leading: const Icon(YaruIcons.folder),
            title: Text(e.key),
          ),
        );
      },
      length: favPathMap.length,
    );
  }
}

class PathGrid extends StatelessWidget {
  const PathGrid({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    const fallBack = XdgIcon(
      name: 'image-x-generic',
      theme: 'Yaru',
      size: 60,
    );
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
                            e.path.endsWith('.png') ||
                                    e.path.endsWith('.jpg') ||
                                    e.path.endsWith('.webp') ||
                                    e.path.endsWith('.jpeg')
                                ? Image.file(
                                    File(e.path),
                                    height: 60,
                                    fit: BoxFit.fitHeight,
                                    filterQuality: FilterQuality.medium,
                                    frameBuilder: (
                                      context,
                                      child,
                                      frame,
                                      wasSynchronouslyLoaded,
                                    ) {
                                      return frame == null ? fallBack : child;
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            fallBack,
                                  )
                                : e.path.endsWith('.mp3')
                                    ? const XdgIcon(
                                        name: 'audio-x-mpeg',
                                        theme: 'Yaru',
                                        size: 64,
                                      )
                                    : isDir(e)
                                        ? const XdgIcon(
                                            name: 'folder',
                                            theme: 'Yaru',
                                            size: 64,
                                          )
                                        : const XdgIcon(
                                            name: 'text-x-generic',
                                            theme: 'Yaru',
                                            size: 64,
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
    super.key,
    required this.path,
    this.includeBackButton = true,
  });

  final String path;
  final bool includeBackButton;

  @override
  Widget build(BuildContext context) {
    return YaruDetailPage(
      appBar: YaruWindowTitleBar(
        leading: includeBackButton
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
            : null,
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
  return Directory(e.path).existsSync();
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
