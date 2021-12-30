import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CoinGeckoConnector {
  // String _urlBase = "https://api.coingecko.com/api/v3/coins/";

  // bitcoin/market_chart/range?vs_currency=eur&from=1392577232&to=1422577232

  // Convert the date part of a DateTime to midnight UTC
  DateTime midnightUTC(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

  // Gets data from CoinGecko
  Future<String> getMarketChartRange(
      String coin, String vs_currency, DateTimeRange when) async {
    // The DateTimeRange probably is in the local time zone
    int t1 = (midnightUTC(when.start).millisecondsSinceEpoch / 1000).floor();
    int t2 = (midnightUTC(when.end).millisecondsSinceEpoch / 1000).floor();

    http.Response response = await http.get(Uri.https(
        "api.coingecko.com", "api/v3/coins/" + coin + "/market_chart/range", {
      "from": t1.toString(),
      "to": t2.toString(),
      "vs_currency": vs_currency
    }));
    // print("Response ${response.body.toString()}");
    return response.body;
  }
}
