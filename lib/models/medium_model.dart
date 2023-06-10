import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:photo_gallery/photo_gallery.dart';

class Media {
  late String id;
  DateTime? date;
  String? name;
  MediumType? type;
  late Image thumbnail;
  late String path;
  late int size;

  Media._create(Medium medium) {
    id = medium.id;
    date = medium.creationDate;
    name = medium.filename;
    type = medium.mediumType;
    thumbnail = Image(
      image: ThumbnailProvider(
        mediumId: id,
        width: 220,
        height: 220,
      ),
    );
  }

  static Future<Media> create(Medium medium) async {
    Media media = Media._create(medium);
    await media._asyncInit(medium);
    return media;
  }

  _asyncInit(Medium medium) async {
    File file = await medium.getFile();
    path = file.absolute.path;
    size = await file.length();
  }
}
