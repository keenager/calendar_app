import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const fetchUrl =
    'https://keenager-calendar.netlify.app/.netlify/functions/getData';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<http.Response> response;

  @override
  void initState() {
    super.initState();
    response = http.get(Uri.parse(fetchUrl));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: response,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error has occured...'),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No data...'),
          );
        }
        return NewsList(snapshot.data!);
      },
    );
  }
}

class NewsList extends StatelessWidget {
  final http.Response response;
  const NewsList(this.response, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> newsList = json.decode(response.body);
    var newsList2 = [];

    newsList.forEach((news) {
      newsList2
        ..add(news['newsName'])
        ..addAll(news['articleList']);
    });

    return ListView.separated(
      itemCount: newsList2.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: newsList2[index] is String
              ? Text(
                  newsList2[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )
              : Text(newsList2[index]['title']),
          onTap: () async {
            if (newsList2[index] is String) {
              return;
            }

            Uri _url = Uri.parse(newsList2[index]['link']);
            if (!_url.hasScheme) {
              _url = _url.replace(scheme: 'https');
            }

            try {
              await launchUrl(_url);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$_url 를 열 수 없습니다.'),
                ),
              );
            }
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
