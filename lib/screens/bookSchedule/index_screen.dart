import 'package:calendar_app/utils/confirm_delete.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BookScheduleIndexScreen extends StatelessWidget {
  const BookScheduleIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String totalPage = '';
    String dailyPage = '';

    final box = Hive.box('myBox');
    final Map<dynamic, dynamic>? savedData = box.get('bookSchedule');
    final castedEntries = savedData?.entries.map((entry) {
      var key = entry.key as String;
      var tmp = entry.value as List;
      var value = tmp.map((e) => e as List<String>).toList();
      return MapEntry(key, value);
    });
    final Map<String, List<List<String>>> savedAllSchedules =
        Map.fromEntries(castedEntries ?? {});
    final List<String> bookList = savedAllSchedules.keys.toList();

    Map<String, int> getScheduleInfo(String title) {
      var schedule = savedAllSchedules[title];
      int lastReadIndex = schedule!.lastIndexWhere((row) => row[3] != '');
      //row[3]이 모두 ''이면, 즉 아직 전혀 읽지 않은 상태라면 lastReadIndex = -1 이 됨.
      int lastReadPage =
          lastReadIndex >= 0 ? int.parse(schedule[lastReadIndex][3]) : 0;
      int totalPage = int.parse(schedule.last[1]);
      return {
        'total': totalPage,
        'current': lastReadPage,
      };
    }

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
                key: formKey,
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
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
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
                itemCount: bookList.length,
                itemBuilder: (context, index) {
                  var scheduleInfo = getScheduleInfo(bookList[index]);
                  int total = scheduleInfo['total']!;
                  int current = scheduleInfo['current']!;
                  double process = current / total;

                  return Dismissible(
                    key: ValueKey(bookList[index]),
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
                      savedData!.remove(bookList[index]);
                      box.put('bookSchedule', savedData);
                    },
                    child: ListTile(
                      title: LinearPercentIndicator(
                        width: MediaQuery.sizeOf(context).width * 0.65,
                        lineHeight: 12,
                        percent: process,
                        progressColor: Colors.lightBlue,
                        animation: true,
                        animationDuration: 1000,
                        leading: Text(bookList[index],
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
                            'title': bookList[index],
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
