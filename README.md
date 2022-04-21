# flutter-image-caching

This project is an example on how to images in Flutter.

# How it works?

This project implements a `CachedNetworkImage` widget. It recieves a URL,
and before it downloads the image it checks if it exists in the cache. If
the images does exist, it shows it directly from the cache. Otherwise, it
downloads the image, saves it to the cache and then shows it.

# Dependencies:

The project requires the following dependencies:

- `http`
- `hive` and `hive_flutter`
- `path_provider`
- `filesize`

For more information refer to the <a href="pubspec.yaml">pubspec.yaml</a> file.