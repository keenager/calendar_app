import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class BookScheduleDetailScreen extends StatefulWidget {
  const BookScheduleDetailScreen({Key? key}) : super(key: key);

  @override
  State<BookScheduleDetailScreen> createState() => _BookScheduleScreenState();
}

class _BookScheduleScreenState extends State<BookScheduleDetailScreen> {
  final box = Hive.box('myBox');
  List<String> colNames = ['날짜', '계획', '수정', '실행'];
  // var bookSchedule = {
  //   'book1': [
  //     ['2023-01-01', '20', '19'],
  //     ['2023-01-02', '21', '20'],
  //     ['2023-01-03', '22', '21'],
  //     ['2023-01-04', '23', '22'],
  //     ['2023-01-05', '24', ''],
  //   ],
  //   'book2': [
  //     [],
  //     [],
  //   ],
  // };
  late final Map<String, List<List<String>>>? _savedAllSchedules;
  List<List<String>> _currentSchedule = [];
  String title = '';
  int totalPage = 0;
  int dailyPage = 0;

  List<List<String>> createSchedule(
      String title, int totalPage, int dailyPage) {
    List<List<String>> result = [];
    DateTime date = DateTime.now();
    int page = dailyPage;
    while (page < totalPage + dailyPage) {
      if (page > totalPage) page = totalPage;
      result.add([
        date.toString().split(' ').first, //날짜
        page.toString(), //계획
        '', //수정
        '', //실행
      ]);
      date = date.add(const Duration(days: 1));
      page += dailyPage;
    }
    return result;
  }

  void updateSchedule(
    BuildContext context,
    int rowIndex,
    int cellIndex,
  ) async {
    var controller = TextEditingController();
    String? inputText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('실제 읽은 페이지'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (inputText == null) {
      return;
    }

    _currentSchedule[rowIndex][cellIndex] = inputText;
    int plannedPage =
        int.parse(_currentSchedule[rowIndex][colNames.indexOf('계획')]);
    int readPage = int.parse(inputText);

    if (plannedPage != readPage) {
      //현재 rowIndex 이후의 리스트를 새로 생성
      List<List<String>> newSubList = [];
      DateTime date = DateTime.parse(_currentSchedule[rowIndex][0]);
      int modifiedPage = readPage;

      do {
        date = date.add(const Duration(days: 1));
        if (plannedPage < totalPage) {
          plannedPage += dailyPage;
        }
        if (totalPage < plannedPage && plannedPage < totalPage + dailyPage) {
          plannedPage = totalPage;
        }
        if (modifiedPage < totalPage) {
          modifiedPage += dailyPage;
        }
        if (totalPage < modifiedPage && modifiedPage < totalPage + dailyPage) {
          modifiedPage = totalPage;
        }

        newSubList.add([
          date.toString().split(' ').first,
          plannedPage.toString(),
          modifiedPage.toString(),
          '',
        ]);
      } while (plannedPage != totalPage || modifiedPage != totalPage);

      // 현재 rowIndex 이후 부분을 새로 만든 인덱스로 대체
      _currentSchedule.replaceRange(
          rowIndex + 1, _currentSchedule.length, newSubList);
    }
    setState(() {});
  }

  void saveSchedule(List<List<String>> currentSchedule) {
    var newAllSchedules = _savedAllSchedules ?? {};
    newAllSchedules[title] = currentSchedule;
    box.put('bookSchedule', newAllSchedules);
  }

  @override
  void initState() {
    super.initState();
    Map<dynamic, dynamic>? savedData = box.get('bookSchedule');
    var castedEntries = savedData?.entries.map((entry) {
      var key = entry.key as String;
      var tmp = entry.value as List;
      var value = tmp.map((e) => e as List<String>).toList();
      return MapEntry(key, value);
    });
    _savedAllSchedules = Map.fromEntries(castedEntries ?? {});
  }

  @override
  Future<void> didChangeDependencies() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    title = args['title']!;
    if (args['isNew'] == 'true') {
      totalPage = int.parse(args['totalPage']!);
      dailyPage = int.parse(args['dailyPage']!);
      _currentSchedule = createSchedule(title, totalPage, dailyPage);
    } else {
      _currentSchedule = _savedAllSchedules![title] as List<List<String>>;
      totalPage = int.parse(_currentSchedule.last[colNames.indexOf('계획')]);
      dailyPage = int.parse(_currentSchedule[0][colNames.indexOf('계획')]);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('독서 계획($title)'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '<총 $totalPage페이지, 하루 $dailyPage페이지>',
            style: const TextStyle(fontSize: 20),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: List<DataColumn>.generate(
                    colNames.length,
                    (index) => DataColumn(label: Text(colNames[index])),
                  ),
                  rows: List<DataRow>.generate(
                    _currentSchedule.length,
                    (rowIndex) => DataRow(
                      color: _currentSchedule[rowIndex]
                                  [colNames.indexOf('날짜')] ==
                              DateTime.now().toString().split(' ').first
                          ? MaterialStatePropertyAll(Colors.deepOrange[100])
                          : null,
                      cells: List<DataCell>.generate(
                        colNames.length,
                        (cellIndex) {
                          if (cellIndex == colNames.indexOf('실행')) {
                            return DataCell(
                              Text(_currentSchedule[rowIndex][cellIndex]),
                              showEditIcon: true,
                              onTap: () {
                                updateSchedule(context, rowIndex, cellIndex);
                              },
                            );
                          } else if (rowIndex > 0 &&
                              _currentSchedule[rowIndex - 1][cellIndex] ==
                                  totalPage.toString()) {
                            return const DataCell(Text('-'));
                          } else {
                            return DataCell(
                                Text(_currentSchedule[rowIndex][cellIndex]));
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 45, 15),
              child: ElevatedButton(
                onPressed: () {
                  try {
                    saveSchedule(_currentSchedule);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('저장하였습니다.')));
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('저장'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
