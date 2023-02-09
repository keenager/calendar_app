import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../models/medium_model.dart';

Widget thumbnailGridview({
  required BuildContext context,
  required List<Media> mediaList,
}) {
  final mp = context.read<MediaProvider>();

  return GridView.builder(
    gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
    itemCount: mediaList.length,
    itemBuilder: (context, index) => Stack(
      children: [
        Card(
          child: Image(
            width: 120,
            height: 120,
            image: ThumbnailProvider(
              mediumId: mediaList[index].id,
              // width: 120,
              // height: 120,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Checkbox(
            value: context.watch<MediaProvider>().checkList[index],
            onChanged: (newValue) {
              // inspect(context.read<MediaProvider>().checkList);
              mp.updateCheckList(index: index, newValue: newValue!);
              mp.updateNumSize();
            },
          ),
        ),
      ],
    ),
  );
}
