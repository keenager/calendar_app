import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import '../utils/error_dialog.dart';
import '../widgets/thumbnail_gridview.dart';
import '../providers/media_provider.dart';

class CafeUploadScreen extends StatefulWidget {
  const CafeUploadScreen({Key? key}) : super(key: key);

  @override
  State<CafeUploadScreen> createState() => _CafeUploadScreenState();
}

class _CafeUploadScreenState extends State<CafeUploadScreen> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final mp = context.read<MediaProvider>();
    mp.getLastDate();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: thumbnailGridview(
                context: context,
                mediaList: context.watch<MediaProvider>().mediaList,
              ),
            ),
            const SizedBox(height: 10),
            Text('사진 ${context.watch<MediaProvider>().totalImageNum}개, '
                '동영상 ${context.watch<MediaProvider>().totalVideoNum}개, '
                '총 ${context.watch<MediaProvider>().totalFileSize}MB'),
            const SizedBox(height: 10),
            Text('(지난번 업로드: ${context.watch<MediaProvider>().lastDate})'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      DatePicker.showDatePicker(
                        context,
                        locale: LocaleType.ko,
                        minTime: DateTime(2018, 11, 5),
                        maxTime: DateTime(2027, 11, 5),
                        onConfirm: (time) {
                          setState(() {
                            _selectedDate = time;
                          });
                        },
                      );
                    },
                    child: Text(_selectedDate == null
                        ? '날짜 선택'
                        : '${_selectedDate!.year}년 ${_selectedDate!.month}월')),
                ElevatedButton(
                  onPressed: () {
                    mp.getMediaList(_selectedDate);
                  },
                  child: const Text('사진 불러오기', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    mp.removeMediaWhichIs(checked: false);
                  },
                  child: const Text('미체크 제거', style: TextStyle(fontSize: 15)),
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: context.watch<MediaProvider>().dropdownValue,
                  items: MediaProvider.dropdownValueList
                      .map((int anum) => DropdownMenuItem<int>(
                            value: anum,
                            child: Text('$anum'),
                          ))
                      .toList(),
                  onChanged: (int? newValue) {
                    mp.updateDropdownValue(newValue!);
                  },
                ),
                const Text('개씩'),
                TextButton(
                  onPressed: mp.selectMediaByDropdownValue,
                  child: const Text('선택'),
                ),
                ElevatedButton(
                  onPressed: () {
                    mp.mediaList.asMap().forEach((index, media) {
                      mp.updateCheckList(index: index, newValue: true);
                    });
                    mp.updateNumSize();
                  },
                  child: const Text('모두 선택', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String uploadResult = await mp.uploadMedia();
                      // 업로드 하지 않았을 경우 이후 작업 생략하기.
                      if (uploadResult != 'success') return;

                      bool? result = await mp.askToMoveMedia(context);
                      // 동의했을 때만 옮기기
                      if (result == true) {
                        await mp.moveMedia();
                      }
                      // 리스트에서 제거
                      mp.removeMediaWhichIs(checked: true);
                      // saveLastDate()
                      await mp.saveLastDate(_selectedDate!);
                      await mp.getLastDate();
                      // 정해진 갯수만큼 선택
                      mp.selectMediaByDropdownValue();
                    } catch (e) {
                      errorDialog(context, e.toString());
                    }
                  },
                  child: const Text('공유', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
