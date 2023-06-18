import 'package:flutter/material.dart';

Future<bool> confirmDelete(BuildContext context) async {
  bool isConfirm = false;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: const Text(
        '삭제할까요?',
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
