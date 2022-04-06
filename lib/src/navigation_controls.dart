import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationControls extends StatelessWidget {
  final Completer<WebViewController> controller;
  const NavigationControls({required this.controller, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller.future,
      builder: (context, snapshot) {
        final WebViewController? controller = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done ||
            controller == null) {
          return Row(
            children: const <Widget>[
              Icon(Icons.arrow_back),
              Icon(Icons.arrow_forward),
              Icon(Icons.replay),
            ],
          );
        }
        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                if (await controller.canGoBack()) {
                  controller.goBack();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No back history item.')),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                if (await controller.canGoForward()) {
                  controller.goForward();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No forward history item.')),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                controller.reload();
              },
            ),
          ],
        );
      },
    );
  }
}
