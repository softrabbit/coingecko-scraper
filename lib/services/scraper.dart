import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CoinGeckoConnector {
  final String _uriAuthorityBase = "api.coingecko.com";
  final String _uriPath = "api/v3";

  // Convert the date part of a DateTime to midnight UTC
  DateTime _midnightUTC(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

  // Expect an array of [timestamp, value] arrays.
  // Assume timestamps are in ascending order and milliseconds.
  // Return list data normalized to closest UTC midnight
  // FIX: first and last day are cut off??
  List _normalizeList(List data) {
    List out = [];
    DateTime t0 = DateTime.fromMillisecondsSinceEpoch(data[0][0], isUtc: true);
    DateTime midnight = _midnightUTC(t0);
    if (t0.hour >= 12) {
      // In the PM we're closer to next midnight
      midnight = _midnightUTC(t0.add(Duration(days: 1)));
    }
    Duration delta0 = t0.difference(midnight);

    for (int i = 1; i < data.length; i++) {
      DateTime t = DateTime.fromMillisecondsSinceEpoch(data[i][0], isUtc: true);
      if (t.difference(midnight).abs() < t0.difference(midnight).abs()) {
        // Go on as long as the difference is shrinking
        t0 = t;
      } else {
        // The previous time was closest to midnight
        out.add([midnight.millisecondsSinceEpoch, data[i - 1][1]]);
        midnight = _midnightUTC(t.add(Duration(days: 1)));
        t0 = t;
      }
    }

    return out;
  }

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
    print("Path: ${uri}");
    print("Query: ${query}");

    return response.body;
  }

  // Gets data, parses JSON and stores it
  Future<String> getMarketChartRange(
      String coin, String vs_currency, DateTimeRange when) async {
    // The DateTimeRange is in the local time zone
    int t1 = (_midnightUTC(when.start).millisecondsSinceEpoch / 1000).floor();
    int t2 = (_midnightUTC(when.end).millisecondsSinceEpoch / 1000).floor();

    String json = await _httpFetch("coins", coin, "market_chart/range", {
      "from": t1.toString(),
      "to": t2.toString(),
      "vs_currency": vs_currency
    });
    var data = jsonDecode(json);
    //print(json);

    // How many days is the longest bearish (downward) trend within a given date range?
    var prices = _normalizeList(data["prices"]);
    List bearish = [prices[0][0], 0]; // Start date, duration
    int bearCount = 0;
    int i;
    for (i = 1; i < prices.length; i++) {
      print(
          "${DateTime.fromMillisecondsSinceEpoch(prices[i][0], isUtc: true)}: ${prices[i][1]}");
      if (prices[i][1] < prices[i - 1][1]) {
        bearCount++;
      }

      if (prices[i][1] >= prices[i - 1][1]) {
        if (bearCount > bearish[1]) {
          bearish = [prices[i - bearCount][0], bearCount];
        }
        bearCount = 0;
      }
    }
    // In case we end in a bearish period
    if (bearCount > bearish[1]) {
      bearish = [prices[i - bearCount][0], bearCount];
    }

    // var marketCaps = _normalizeList(data["market_caps"]);
    // Which date within a given date range had the highest trading volume?
    var totalVolumes = _normalizeList(data["total_volumes"]);
    List maxVolume = totalVolumes[0];
    totalVolumes.forEach((entry) => {
          if (entry[1] > maxVolume[1]) {maxVolume = entry}
        });
    return "${DateTime.fromMillisecondsSinceEpoch(bearish[0], isUtc: true)}: ${bearish[1]}";
  }
}
