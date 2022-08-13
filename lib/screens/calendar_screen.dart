import 'package:calendar_app/controllers/screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _eventDocs;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> _selectedEventDocs;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getEventDocsOfTheMonth(DateTime focusedDay) {
    return _db
        .collection('schedule')
        .where('date',
            isGreaterThanOrEqualTo:
                DateTime(focusedDay.year, focusedDay.month, 1))
        .where('date',
            isLessThan: DateTime(focusedDay.year, focusedDay.month + 1, 1))
        // .orderBy('time', descending: false)
        .get()
        .then((data) => data.docs);
  }

  @override
  void initState() {
    super.initState();
    _eventDocs = getEventDocsOfTheMonth(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _eventDocs,
      builder: (BuildContext context,
          AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
              snapshot) {
        if (snapshot.hasError) {
          return const Text('Some error...');
        } else if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData) {
          return const Text('Document does not exist...');
        }
        // final List<QueryDocumentSnapshot<Map<String, dynamic>>> _eventDocs =
        //     snapshot.data == null ? [] : snapshot.data!.docs;

        List<QueryDocumentSnapshot<Map<String, dynamic>>> getEventDocsOfTheDay(
            DateTime dateTime) {
          return snapshot.data!
              .where((doc) =>
                  doc.data()['date'].toDate().month == dateTime.month &&
                  doc.data()['date'].toDate().day == dateTime.day)
              .toList();
        }

        _selectedEventDocs = getEventDocsOfTheDay(_selectedDay);

        return Column(
          children: [
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2016, 5, 3),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.red),
              ),
              calendarStyle: const CalendarStyle(
                weekendTextStyle: TextStyle(color: Colors.red),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEventDocs = getEventDocsOfTheDay(selectedDay);
                  });
                }
              },
              onDayLongPressed: (day, day2) {
                TextEditingController _controller = TextEditingController();
                Get.defaultDialog(
                  title: '일정 입력',
                  content: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    maxLines: null,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: '일정을 입력하세요.'),
                  ),
                  textConfirm: '저장',
                  confirmTextColor: Colors.white,
                  onConfirm: () async {
                    if (_controller.text.trim() == '') {
                      return;
                    }
                    await _db.collection('schedule').add({
                      'user': Get.find<ScreenController>().user.value,
                      'date': DateTime(day.year, day.month, day.day),
                      'content': _controller.text,
                      'time': Timestamp.now(),
                    });
                    setState(() {
                      _selectedDay = day;
                      _eventDocs = getEventDocsOfTheMonth(day);
                      Get.back();
                    });
                  },
                  textCancel: '취소',
                );
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  // Call `setState()` when updating calendar format
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // No need to call `setState()` here
                setState(() {
                  _focusedDay = focusedDay;
                  _eventDocs = getEventDocsOfTheMonth(focusedDay);
                });
              },
              eventLoader: (day) {
                return getEventDocsOfTheDay(day);
              },
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _selectedEventDocs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: !_selectedEventDocs[index]
                                  .data()
                                  .containsKey('user')
                              ? Colors.white
                              : _selectedEventDocs[index]['user'] == 'YS'
                                  ? Colors.teal
                                  : Colors.orange,
                          maxRadius: 12.0,
                          child: Text(
                            _selectedEventDocs[index].data().containsKey('user')
                                ? _selectedEventDocs[index]['user']
                                : '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          _selectedEventDocs[index]['content'],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Get.defaultDialog(
                          middleText: '이 스케줄을 지울까요?',
                          textCancel: '취소',
                          textConfirm: '삭제',
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            setState(() {
                              _selectedEventDocs[index].reference.delete();
                              _eventDocs = getEventDocsOfTheMonth(_selectedDay);
                              Get.back();
                            });
                          },
                        );
                      },
                    ),
                    onLongPress: () {
                      TextEditingController _controller =
                          TextEditingController();
                      _controller.text =
                          _selectedEventDocs[index].data()['content'];
                      Get.defaultDialog(
                        title: '스케줄 내용 고치기',
                        content: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          autofocus: true,
                          decoration:
                              const InputDecoration(hintText: '일정을 입력하세요.'),
                        ),
                        textCancel: '취소',
                        textConfirm: '수정',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          setState(() {
                            _selectedEventDocs[index]
                                .reference
                                .update({'content': _controller.text});
                            Get.back();
                          });
                        },
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        );
      },
    );
  }
}
