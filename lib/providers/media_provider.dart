import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medium_model.dart';

class MediaProvider with ChangeNotifier {
  List<Media> _mediaList = [];
  int _totalImageNum = 0;
  int _totalVideoNum = 0;
  double _totalFileSize = 0;
  String _lastDate = '없음';
  List<bool> _checkList = [];
  // int _selectStartIndex = 0;
  static const List<int> dropdownValueList = [10, 15, 20];
  int _dropdownValue = dropdownValueList.first;

  List<Media> get mediaList => _mediaList;
  int get totalImageNum => _totalImageNum;
  int get totalVideoNum => _totalVideoNum;
  double get totalFileSize => _totalFileSize;
  String get lastDate => _lastDate;
  List<bool> get checkList => _checkList;
  int get dropdownValue => _dropdownValue;

  Future<void> getMediaList(DateTime? selectedDate) async {
    if (selectedDate == null) {
      return;
    }
    if (await Permission.storage.request().isDenied) {
      return;
    }

    final List<Album> imageAlbums =
        await PhotoGallery.listAlbums(mediumType: MediumType.image);
    Album albumCamera =
        imageAlbums.firstWhere((album) => album.name == 'Camera');
    MediaPage imagePage =
        await albumCamera.listMedia(skip: 0, take: albumCamera.count);

    final List<Album> videoAlbums =
        await PhotoGallery.listAlbums(mediumType: MediumType.video);
    Album albumVideo =
        videoAlbums.firstWhere((album) => album.name == 'Camera');
    MediaPage videoPage =
        await albumVideo.listMedia(skip: 0, take: albumVideo.count);

    // 사진,동영상 리스트
    List<Medium> mediumList = [
      ...imagePage.items,
      ...videoPage.items,
    ];

    // 생성날짜가 없는 사진은 제외(예전 휴대폰으로 찍은 사진 중에 그런 파일이 있는 듯)
    mediumList.removeWhere((medium) => medium.creationDate is! DateTime);

    // 이번달 생성된 것들 추리기
    List<Medium> selectedList = mediumList
        .where((image) =>
            image.creationDate!.year == selectedDate.year &&
            image.creationDate!.month == selectedDate.month)
        .toList();

    // 정렬
    selectedList.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));

    // Media 객체 리스트 생성
    Iterable<Future<Media>> futures =
        selectedList.map((medium) => Media.create(medium));
    _mediaList = await Future.wait(futures);

    // 체크박스용 체크리스트 생성
    _checkList = List.generate(_mediaList.length, (_) => true);

    // 개수, 용량 업데이트
    updateNumSize();
    // notifyListeners();
  }

  Future<void> getLastDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedStr = prefs.getString('lastDate');
    if (savedStr == null) return;
    DateTime lastDateTime = DateTime.parse(savedStr);
    _lastDate = '${lastDateTime.year}년 ${lastDateTime.month}월';
    notifyListeners();
  }

  Future<void> saveLastDate(DateTime selectedDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastDate', selectedDate.toString().split(' ')[0]);
  }

  bool isChecked(Media media) {
    return checkList[mediaList.indexOf(media)];
  }

  void updateNumSize() {
    _totalImageNum = mediaList
        .where((media) => isChecked(media) && media.type == MediumType.image)
        .length;
    _totalVideoNum = mediaList
        .where((media) => isChecked(media) && media.type == MediumType.video)
        .length;
    int totalBytes = mediaList.fold<int>(
        0, (prev, media) => prev + (isChecked(media) ? media.size : 0));
    _totalFileSize =
        double.parse((totalBytes / 1024 / 1024).toStringAsFixed(2));

    notifyListeners();
  }

  void updateCheckList({required int index, required bool newValue}) {
    _checkList[index] = newValue;
    notifyListeners();
  }

  void removeMediaWhichIs({required bool checked}) {
    _mediaList.removeWhere(
        (media) => checkList[_mediaList.indexOf(media)] == checked);
    _checkList.removeWhere((element) => element == checked);
    // _selectStartIndex = 0;
    notifyListeners();
  }

  // void startIndexToZero() {
  //   _selectStartIndex = 0;
  // }

  // // 설정한 숫자씩 선택  -> 업로드하고 리스트에서 삭제하면 굳이 필요 없나?
  // void toggleSelectMedia(int cnt) {
  //   if (_selectStartIndex > checkList.length) {
  //     startIndexToZero();
  //   }
  //   for (int i = 0; i < checkList.length; i++) {
  //     if (_selectStartIndex <= i && i < _selectStartIndex + cnt) {
  //       checkList[i] = true;
  //     } else {
  //       checkList[i] = false;
  //     }
  //   }
  //   updateNumSize();
  //   // notifyListeners();
  //   _selectStartIndex += cnt;
  // }

  void updateDropdownValue(int newValue) {
    _dropdownValue = newValue;
    notifyListeners();
  }

  void selectMediaByDropdownValue() {
    mediaList.asMap().forEach((index, media) {
      bool newValue = index < dropdownValue ? true : false;
      updateCheckList(index: index, newValue: newValue);
    });
    updateNumSize();
  }

  Future<String> uploadMedia() async {
    List<XFile> files = [];

    //체크된 것만 리스트에 담기
    for (Media media in mediaList) {
      if (isChecked(media)) {
        files.add(XFile(media.path));
      }
    }
    // 업로드 여부 결과값
    ShareResult result = await Share.shareXFiles(files);

    return result.status.name; // success or dismissed or unavailable
  }

  Future<bool?> askToMoveMedia(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('복사?'),
        content: const Text('하율 폴더로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              // var navi = Navigator.of(context);
              // await moveMedia();
              // navi.pop();
            },
            child: const Text('네'),
          ),
        ],
      ),
    );
  }

  //다른 폴더로 이동
  Future<void> moveMedia() async {
    //권한 확인
    if (await Permission.manageExternalStorage.request().isDenied) {
      return;
    }

    //체크된 것 리스트 생성
    List<Media> selectedList =
        mediaList.where((media) => isChecked(media)).toList();

    //이동할 폴더 경로 생성
    List<String> newDirPathList = selectedList[0].path.split('/')
      ..removeLast()
      ..removeLast()
      ..add('하율');
    String newDirPath = newDirPathList.join('/');

    //폴더 없으면 생성
    await Directory(newDirPath).create();

    //rename 방식으로 이동
    var futures = selectedList.map((media) {
      File file = File(media.path);
      String newFilePath = '$newDirPath/${media.name!}';
      return file.rename(newFilePath);
    });
    await Future.wait(futures);
  }
}
