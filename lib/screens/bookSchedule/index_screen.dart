import 'package:calendar_app/utils/confirm_delete.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BookScheduleIndexScreen extends StatefulWidget {
  const BookScheduleIndexScreen({super.key});

  @override
  State<BookScheduleIndexScreen> createState() =>
      _BookScheduleIndexScreenState();
}

class _BookScheduleIndexScreenState extends State<BookScheduleIndexScreen> {
  final box = Hive.box('myBox');
  Map<dynamic, dynamic>? _savedData;
  late final List<String> _bookList;
  late final Map<String, List<List<String>>>? _savedAllSchedules;
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String totalPage = '';
  String dailyPage = '';

  Map<String, int> getScheduleInfo(String title) {
    var schedule = _savedAllSchedules![title];
    var lastReadIndex = schedule!.lastIndexWhere((row) => row[3] != '');
    int lastReadPage =
        lastReadIndex >= 0 ? int.parse(schedule[lastReadIndex][3]) : 0;
    int totalPage = int.parse(schedule.last[1]);
    return {
      'total': totalPage,
      'current': lastReadPage,
    };
  }

  @override
  void initState() {
    super.initState();
    _savedData = box.get('bookSchedule');
    // setState(() {
    _bookList = _savedData?.keys.map((e) => e as String).toList() ?? [];
    // });
    var castedEntries = _savedData?.entries.map((entry) {
      var key = entry.key as String;
      var tmp = entry.value as List;
      var value = tmp.map((e) => e as List<String>).toList();
      return MapEntry(key, value);
    });
    _savedAllSchedules = Map.fromEntries(castedEntries ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('독서 계획'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: '책 이름'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력하세요.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        title = newValue!;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(labelText: '총 페이지'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '페이지 숫자를 입력하세요.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        totalPage = newValue!;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(labelText: '하루 읽을 페이지'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '페이지 숫자를 입력하세요.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        dailyPage = newValue!;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pushNamed(
                    context,
                    '/book/detail',
                    arguments: <String, String>{
                      'isNew': 'true',
                      'title': title,
                      'totalPage': totalPage,
                      'dailyPage': dailyPage,
                    },
                  );
                }
              },
              child: const Text('만들기'),
            ),
            const Divider(
              height: 50,
              thickness: 1.5,
              indent: 10,
              endIndent: 10,
            ),
            const Text('저장된 스케줄'),
            Expanded(
              child: ListView.separated(
                itemCount: _bookList.length,
                itemBuilder: (context, index) {
                  var scheduleInfo = getScheduleInfo(_bookList[index]);
                  int total = scheduleInfo['total']!;
                  int current = scheduleInfo['current']!;
                  double process = current / total;

                  return Dismissible(
                    key: ValueKey(_bookList[index]),
                    background: Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          2,
                          (_) => const Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await confirmDelete(context);
                    },
                    onDismissed: (direction) {
                      _savedData!.remove(_bookList[index]);
                      box.put('bookSchedule', _savedData);
                    },
                    child: ListTile(
                      title: LinearPercentIndicator(
                        width: MediaQuery.sizeOf(context).width * 0.65,
                        lineHeight: 12,
                        percent: process,
                        progressColor: Colors.lightBlue,
                        animation: true,
                        animationDuration: 1000,
                        leading: Text(_bookList[index],
                            style: const TextStyle(fontSize: 20)),
                        trailing: Text('${(process * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 20)),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/book/detail',
                          arguments: <String, String>{
                            'isNew': '',
                            'title': _bookList[index],
                          },
                        );
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
