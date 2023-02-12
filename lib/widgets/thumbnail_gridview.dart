import 'dart:io';
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
    itemBuilder: (context, index) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(mp.mediaList[index].name!),
                  content: mp.mediaList[index].type == MediumType.image
                      ? Image(
                          image: FileImage(File(mp.mediaList[index].path)),
                        )
                      : const Text('동영상 입니다.'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('확인')),
                  ],
                ),
              );
            },
            child: Card(
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
      );
    },
  );
}
