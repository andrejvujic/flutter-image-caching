import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_caching/cached_network_image.dart';

class ViewCache extends StatelessWidget {
  const ViewCache({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> urls = List<String>.from(
      Hive.box('cache').keys.toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${urls.length} images'),
      ),
      body: ListView.separated(
        separatorBuilder: (
          BuildContext context,
          int index,
        ) =>
            const SizedBox(height: 24.0),
        itemCount: urls.length,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          final String url = urls.elementAt(index);
          final Map<String, dynamic> element = Map<String, dynamic>.from(
            Hive.box('cache').get(url),
          );

          return Stack(
            key: ValueKey<String>(url),
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              SizedBox(
                width: 300.0,
                height: 300.0,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  key: ValueKey<String>(url),
                  url: url,
                ),
              ),
              Container(
                color: Theme.of(context).accentColor,
                child: Text(
                  filesize(
                    element['bytes'].lengthInBytes,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
