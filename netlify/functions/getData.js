const axios = require("axios");
const cheerio = require("cheerio");

const newsData = {
  hani_editorial: {
    title: "한겨레 사설,칼럼",
    url: "https://www.hani.co.kr/arti/opinion/editorial/",
    className: "div.list h4.ranktitle",
  },
  hani_most: {
    title: "한겨례 많이 본 기사",
    url: "https://www.hani.co.kr/arti/list.html",
    className: "div.list h4.ranktitle",
  },
  khan_opinion: {
    title: "경향 오피니언",
    url: "https://www.khan.co.kr/opinion",
    className: ".art-list li",
  },
  khan_most: {
    title: "경향 종합 실시간",
    url: "https://www.khan.co.kr/realtime/articles",
    className: ".art-list li",
  },
  sisain1: {
    title: "시사인 주요 기사 1",
    url: "https://www.sisain.co.kr",
    className: "li.auto-col",
  },
  sisain2: {
    title: "시사인 주요 기사 2",
    url: "https://www.sisain.co.kr",
    className: "li.clearfix",
  },
  joongang: {
    title: "중앙 사설,칼럼",
    url: "https://www.joongang.co.kr/opinion/editorialcolumn",
    className: "#story_list div.card_body h2",
  },
  peppermint: {
    title: "뉴스 페퍼민트",
    url: "https://newspeppermint.com/",
    className: "h6",
  },
};

exports.handler = async function (event, context) {
  // const newsName = event.queryStringParameters.newsName;
  const newsNameList = Object.keys(newsData);

  async function getHTML(url) {
    try {
      let response = await axios.get(url);
      return response.data;
    } catch (error) {
      console.error(error);
    }
  }

  async function getArticleList(newsName) {
    const url = newsData[newsName].url;
    const className = newsData[newsName].className;
    const html = await getHTML(url);
    let result = [];

    const $ = cheerio.load(html);
    let $list = $(className);
    for (let i = 0; i < $list.length; i++) {
      //   console.log($list.eq(i).children("a"));
      let link = $list.eq(i).children("a").attr("href");
      if (url.includes("sisain")) {
        link = "https://www.sisain.co.kr" + link;
      }
      let text =
        $list.eq(i).children("a").children().first().text() || // 시사인
        $list.eq(i).children("a").text(); // 나머지
      result[i] = { title: text, link: link };
    }
    return result;
  }

  let newsList = [];
  try {
    let temp = await Promise.allSettled(
      newsNameList.map((newsName) => getArticleList(newsName))
    );

    newsList = newsNameList.map((newsName, index) => {
      return {
        newsName: newsData[newsName].title,
        articleList: temp[index].value,
      };
    });
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: "Error has occured: " + err,
    };
  }

  return {
    statusCode: 200,
    headers: {
      "Content-type": "text/plain; charset=utf-8",
    },
    body: JSON.stringify(newsList),
  };
};
