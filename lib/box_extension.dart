import 'dart:typed_data';

import 'package:filesize/filesize.dart';
import 'package:hive/hive.dart';

/// Created by Andrej
/// April 21, 2022

extension BoxExtension on Box {
  /// This Hive box extension allows the calculation of the
  /// size of the box in bytes.
  /// Important: only calculates the size of elements which have
  /// the Uint8List runtime type.
  int get sizeInBytes {
    final Box box = this;

    int totalSize = 0;

    final _ = Uint8List.fromList(
      const <int>[],
    );

    for (int i = 0; i < box.length; i++) {
      final Map<String, dynamic> element = Map<String, dynamic>.from(
        box.values.elementAt(i),
      );
      int elementSize = 0;

      element.values.forEach(
        (value) {
          if (value.runtimeType == _.runtimeType)
            elementSize = elementSize + value.lengthInBytes;
        },
      );

      totalSize = totalSize + elementSize;
    }

    return totalSize;
  }

  /// Formats the size using the filesize package.
  String get formattedSize => filesize(sizeInBytes);
}
