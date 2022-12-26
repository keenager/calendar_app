import 'package:calendar_app/constants/news_data_list.dart';
import 'package:calendar_app/utils/get_article_list.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<List<Map<String, String?>>>> futureListOfArticleList;

  @override
  void initState() {
    super.initState();
    var futureList =
        newsDataList.map((newsData) => getArticleList(newsData)).toList();
    futureListOfArticleList = Future.wait(futureList);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Map<String, String?>>>>(
      future: futureListOfArticleList,
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
  final List<List<Map<String, String?>>> listOfArticleList;

  const NewsList(this.listOfArticleList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var newsList = [];

    listOfArticleList.asMap().forEach((index, articleList) {
      newsList
        ..add(newsDataList[index]['title'])
        ..addAll(articleList);
    });

    return ListView.separated(
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: newsList[index] is String
              ? Text(
                  newsList[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )
              : Text(newsList[index]['title']),
          onTap: () async {
            if (newsList[index] is String) {
              return;
            }

            Uri url = Uri.parse(newsList[index]['link']);
            if (!url.hasScheme) {
              url = url.replace(scheme: 'https');
            }

            try {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$url 를 열 수 없습니다.'),
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
