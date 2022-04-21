import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_caching/box_extension.dart';
import 'package:image_caching/cached_network_image.dart';
import 'package:image_caching/view_cache.dart';

import 'package:path_provider/path_provider.dart' as provider;

Future<void> main() async {
  /// This project uses the Hive database to store data.
  /// Read more: https://pub.dev/packages/hive
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android) {
    final dir = await provider.getApplicationDocumentsDirectory();
    final path = dir.path;

    Hive.init(path);
  }

  runApp(
    App(),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image caching example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<bool> initializeHiveDb() async {
    try {
      await Hive.openBox('cache');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  final String baseUrl = "https://picsum.photos/seed";

  String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: initializeHiveDb(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    const LETTERS = 'abcdefghijklmnopqrstuvwxyz';
                    final rnd = math.Random();

                    String seed = '';
                    for (int i = 0; i < 10; i++) {
                      final int _ = rnd.nextInt(LETTERS.length);
                      seed = seed + LETTERS[_];
                    }

                    setState(() => url = '$baseUrl/$seed/300/300');
                  },
                  child: const Text(
                    'Generate new image',
                  ),
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: 300.0,
                  height: 300.0,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    key: ValueKey<String>(
                      '$url',
                    ),
                    url: url,
                  ),
                ),
                const SizedBox(height: 24.0),
                ValueListenableBuilder(
                  valueListenable: Hive.box('cache').listenable(),
                  builder: (
                    BuildContext context,
                    Box box,
                    Widget child,
                  ) {
                    return Text(
                      'Cache: ${box.formattedSize}',
                      style: const TextStyle(fontSize: 16.0),
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () => Hive.box('cache').clear(),
                  child: const Text(
                    'Clear cache',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ViewCache(),
                    ),
                  ),
                  child: const Text(
                    'View cache',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
