import 'package:calendar_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectUser extends StatelessWidget {
  const SelectUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<UserProvider>().getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 선택'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            icon: const Icon(Icons.supervised_user_circle),
            label: Text(context.watch<UserProvider>().user),
            onPressed: null,
          ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<UserProvider>().setUser(context, 'YS');
              },
              child: const Text('용수'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                context.read<UserProvider>().setUser(context, 'MY');
              },
              child: const Text('미영'),
            ),
          ],
        ),
      ),
    );
  }
}
