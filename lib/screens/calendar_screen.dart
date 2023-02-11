import 'package:calendar_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
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
    context.read<UserProvider>().getCurrentUser();
    TextEditingController textController = TextEditingController();

    Future<void> saveSchedule() async {
      if (textController.text.trim() == '') {
        return;
      }
      if (context.read<UserProvider>().user == 'unselected') {
        Navigator.pushNamed(context, '/user');
        return;
      }
      await _db.collection('schedule').add({
        'user': context.read<UserProvider>().user,
        'date':
            DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day),
        'content': textController.text,
        'time': Timestamp.now(),
      });
      setState(() {
        _eventDocs = getEventDocsOfTheMonth(_selectedDay);
        Navigator.pop(context);
      });
    }

    Future<void> updateSchedule(BuildContext context, int index) async {
      textController.text = _selectedEventDocs[index].get('content');
      Timestamp timeStampOfDate = _selectedEventDocs[index].get('date');
      DateTime date = timeStampOfDate.toDate();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            '일정 고치기',
            textAlign: TextAlign.center,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await DatePicker.showDatePicker(
                          context,
                          locale: LocaleType.ko);
                      if (pickedDate != null) {
                        setState(() {
                          date = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      '${date.year}년 ${date.month}월 ${date.day}일',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.text,
                    maxLines: null,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '일정을 입력하세요.',
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.white)),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedEventDocs[index].reference.update({
                    'date': DateTime(date.year, date.month, date.day),
                    'content': textController.text,
                    'time': Timestamp.now(),
                  });
                  _eventDocs = getEventDocsOfTheMonth(_selectedDay);
                  Navigator.pop(context);
                });
              },
              child: const Text('수정'),
            ),
          ],
        ),
      );
    }

    Future<bool> confirmDelete(
        BuildContext context, DismissDirection direction) async {
      bool isConfirm = false;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text(
            '이 스케줄을 지울까요?',
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.white)),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                isConfirm = true;
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
          ],
        ),
      );
      return isConfirm;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('우리의 일정'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            icon: const Icon(Icons.supervised_user_circle),
            label: Text(context.watch<UserProvider>().user),
            onPressed: () => Navigator.pushNamed(context, '/user'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _eventDocs,
        builder: (BuildContext context,
            AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
                snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error occurred...\n${snapshot.error}'));
          } else if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Document does not exist...'));
          }
          // final List<QueryDocumentSnapshot<Map<String, dynamic>>> _eventDocs =
          //     snapshot.data == null ? [] : snapshot.data!.docs;

          List<QueryDocumentSnapshot<Map<String, dynamic>>>
              getEventDocsOfTheDay(DateTime givenDate) {
            return snapshot.data!.where((doc) {
              DateTime fetchedDate = (doc.get('date') as Timestamp).toDate();
              return fetchedDate.month == givenDate.month &&
                  fetchedDate.day == givenDate.day;
            }).toList();
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
                onDayLongPressed: (day, day2) {},
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
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context,
                      day,
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          events) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        events.length,
                        (index) => Icon(
                          Icons.circle,
                          size: 12,
                          color: events[index].data()['user'] == 'YS'
                              ? Colors.teal
                              : Colors.orange,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: _selectedEventDocs.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: ValueKey<Timestamp>(
                          _selectedEventDocs[index].get('time')),
                      background: Container(
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            2,
                            (_) =>
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await confirmDelete(context, direction);
                      },
                      onDismissed: (direction) {
                        setState(() {
                          _selectedEventDocs[index].reference.delete();
                          _eventDocs = getEventDocsOfTheMonth(_selectedDay);
                        });
                      },
                      child: ListTile(
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
                                _selectedEventDocs[index]
                                        .data()
                                        .containsKey('user')
                                    ? _selectedEventDocs[index]['user']
                                    : '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(_selectedEventDocs[index]['content']),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            updateSchedule(context, index);
                          },
                        ),
                        onLongPress: () {},
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('일정 입력', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      '${_selectedDay.year}년 ${_selectedDay.month}월 ${_selectedDay.day}일'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.text,
                    maxLines: null,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '일정을 입력하세요.',
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                ElevatedButton(
                  onPressed: saveSchedule,
                  child: const Text('저장'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
