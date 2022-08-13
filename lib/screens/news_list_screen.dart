import 'dart:async';
import 'dart:convert';
import 'package:calendar_app/screens/news_article_screen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchNewsNames() async {
  Uri url = Uri.parse('http://146.56.136.197/scrap/getNewsNames');
  http.Response response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load...');
  }
}

Future<Map<String, dynamic>> fetchData(String newsName) async {
  Uri url2 = Uri.parse('http://146.56.136.197/scrap/getData/' + newsName);
  http.Response response = await http.get(url2);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load...');
  }
}

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<dynamic>> newsNames;

  @override
  void initState() {
    super.initState();
    newsNames = fetchNewsNames();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: newsNames,
      builder: (context, snapshot) {
        List<dynamic> newsNames = snapshot.data!;
        return NewsList(newsNames);
      },
    );
  }
}

class NewsList extends StatefulWidget {
  final List<dynamic> newsNames;
  const NewsList(this.newsNames, {Key? key}) : super(key: key);

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final controller = Completer<WebViewController>();
  late Future<List<Map<String, dynamic>>> newsList;

  @override
  void initState() {
    super.initState();
    newsList =
        Future.wait(widget.newsNames.map((newsName) => fetchData(newsName)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: newsList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('${snapshot.error}'),
          );
        }

        List<dynamic> newsList = [];
        for (var e in snapshot.data!) {
          newsList = [...newsList, e['newsName'], ...e['newsList']];
        }
        String newsName = '';

        return ListView.separated(
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            if (newsList[index] is String) {
              newsName = newsList[index];
            }
            return ListTile(
              title: newsList[index] is String
                  ? Text(
                      newsName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(newsList[index]['title']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsArticleScreen(
                      newsList[index]['title'],
                      newsList[index]['link'],
                      controller,
                    ),
                  ),
                );
              },
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        );
      },
    );
  }
}
