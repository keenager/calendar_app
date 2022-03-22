import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<String> selectedEvents = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void showMyDialog(
      {required BuildContext context,
      required String title,
      Widget? content,
      required Function callback}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  callback();
                  Navigator.pop(context);
                });
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _db
          .collection('schedule')
          .where('date',
              isGreaterThanOrEqualTo:
                  DateTime(_focusedDay.year, _focusedDay.month, 1))
          .where('date',
              isLessThanOrEqualTo:
                  DateTime(_focusedDay.year, _focusedDay.month, 31))
          // .orderBy('time', descending: false)
          .get(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Center(child: CircularProgressIndicator());
        // }
        if (snapshot.hasError) {
          return const Text('Some error...');
        } else if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return const Text('Document does not exist...');
        }

        final _eventDocs = snapshot.data == null ? [] : snapshot.data!.docs;
        final _selectedEventDocs = _eventDocs
            .where((doc) => doc.data()['date'].toDate().day == _selectedDay.day)
            .toList();

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
                  });
                }
              },
              onDayLongPressed: (day, day2) async {
                TextEditingController _controller = TextEditingController();

                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('일정 입력'),
                    content: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: '일정을 입력하세요.'),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_controller.text.trim() == '') {
                            return;
                          }
                          _db.collection('schedule').add({
                            'date': DateTime(day.year, day.month, day.day),
                            'content': _controller.text,
                            'time': Timestamp.now(),
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                );

                setState(() {
                  _selectedDay = day;
                });
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
                });
              },
              eventLoader: (day) {
                final sameDayDocs = _eventDocs.where((e) =>
                    e.data()['date'].toDate().month == day.month &&
                    e.data()['date'].toDate().day == day.day);
                return sameDayDocs.toList();
              },
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _selectedEventDocs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_selectedEventDocs[index]['content']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showMyDialog(
                          context: context,
                          title: '스케줄 지우기?',
                          callback: () {
                            _selectedEventDocs[index].reference.delete();
                          },
                        );
                      },
                    ),
                    onLongPress: () {
                      TextEditingController _controller =
                          TextEditingController();
                      _controller.text =
                          _selectedEventDocs[index].data()['content'];
                      showMyDialog(
                        context: context,
                        title: '스케줄 내용 고치기',
                        content: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          autofocus: true,
                          decoration:
                              const InputDecoration(hintText: '일정을 입력하세요.'),
                        ),
                        callback: () {
                          _selectedEventDocs[index]
                              .reference
                              .update({'content': _controller.text});
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
