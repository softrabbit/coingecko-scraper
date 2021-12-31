import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:coingecko_scraper/services/numbercruncher.dart';

class CoinGeckoConnector {
  final String _uriAuthorityBase = "api.coingecko.com";
  final String _uriPath = "api/v3";

  // Get JSON off the server.
  // TODO: error handling...
  Future<String> _httpFetch(String cmd, String? param, String? subcmd,
      Map<String, dynamic>? query) async {
    String uri = _uriPath +
        "/" +
        cmd +
        (param != null ? "/" + param : "") +
        (subcmd != null ? "/" + subcmd : "");
    http.Response response = await http.get(
        Uri.https(_uriAuthorityBase, uri, query),
        headers: {"Accept": "application/json"});

    return response.body;
  }

  // Gets data, parses JSON and returns it
  // as a Map containing:
  //     "longestBearish": [DateTime start, num days]
  //     "maxVolume": [DateTime day, num volume],
  //     "optimalDates": [DateTime buy, DateTime sell]
  Future<Map> getMarketChartRange(
      String coin, String vs_currency, DateTimeRange when) async {
    // The DateTimeRange is in the local time zone
    int t1 =
        (numberCruncher.midnightUTC(when.start).millisecondsSinceEpoch / 1000)
            .floor();
    // Add some hours to get past midnight
    int t2 =
        (numberCruncher.midnightUTC(when.end).millisecondsSinceEpoch / 1000 +
                43200)
            .floor();

    String json = await _httpFetch("coins", coin, "market_chart/range", {
      "from": t1.toString(),
      "to": t2.toString(),
      "vs_currency": vs_currency
    });
    var data = jsonDecode(json);

    var prices = numberCruncher.normalizeList(data["prices"]);
    List bearish = numberCruncher.getBearish(prices);
    bearish[0] = DateTime.fromMillisecondsSinceEpoch(bearish[0], isUtc: true);

    // var marketCaps = _normalizeList(data["market_caps"]);
    var totalVolumes = numberCruncher.normalizeList(data["total_volumes"]);
    List maxVolume = numberCruncher.getMaxVolume(totalVolumes);
    maxVolume[0] =
        DateTime.fromMillisecondsSinceEpoch(maxVolume[0], isUtc: true);
    // return "${DateTime.fromMillisecondsSinceEpoch(bearish[0], isUtc: true)}: ${bearish[1]}";

    List optimalDates = numberCruncher.getOptimalTradeDates(prices);
    if (optimalDates.length == 2) {
      optimalDates = [
        DateTime.fromMillisecondsSinceEpoch(optimalDates[0], isUtc: true),
        DateTime.fromMillisecondsSinceEpoch(optimalDates[1], isUtc: true)
      ];
    }

    return {
      "longestBearish": bearish,
      "maxVolume": maxVolume,
      "optimalDates": optimalDates
    };
  }
}
