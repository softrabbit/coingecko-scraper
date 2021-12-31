import 'package:flutter/material.dart';
import 'dart:async';
import 'package:coingecko_scraper/services/scraper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTimeRange? _when;
  String _dateRange = "Press the button to set date range.";
  String _bearish = "";
  String _highestVolume = "";
  String _optimalDates = "";
  // These two could come from some kind of selection widget
  final String _coin = "bitcoin";
  final String _currency = "eur";
  CoinGeckoConnector conn = CoinGeckoConnector();

  String _toDateString(DateTime dt) {
    return dt.year.toString() +
        "-" +
        dt.month.toString().padLeft(2, '0') +
        "-" +
        dt.day.toString().padLeft(2, '0');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
        initialDateRange: _when,
        context: context,
        firstDate: DateTime(2009, 1, 1), // Bitcoin released 2009-01-03
        lastDate: DateTime.now());
    if (pickedRange != null && pickedRange != _when) {
      // TODO: add progressindicator while loading
      setState(() {
        _when = pickedRange;
        _dateRange =
            _toDateString(_when!.start) + " - " + _toDateString(_when!.end);
        _bearish = '';
        _highestVolume = '';
        _optimalDates = '';
      });
      Map response =
          await conn.getMarketChartRange(_coin, _currency, pickedRange);
      setState(() {
        _bearish = "Longest bearish period: " +
            "${_toDateString(response["longestBearish"][0])}, " +
            "${response["longestBearish"][1]} days";
        _highestVolume = "Highest trading volume: " +
            "${_toDateString(response["maxVolume"][0])}, " +
            "${response["maxVolume"][1]} ${_currency}";
        _optimalDates = response["optimalDates"].length == 0
            ? "Trading in this period not advisable."
            : "Buy low: ${_toDateString(response["optimalDates"][0])}, " +
                "Sell high: ${_toDateString(response["optimalDates"][1])}";
      });
    }
  }

  // Invoke "debug painting" (press "p" in the console, choose the
  // "Toggle Debug Paint" action from the Flutter Inspector in Android
  // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
  // to see the wireframe for each widget.
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically.

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _dateRange,
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              _bearish,
            ),
            Text(
              _highestVolume,
            ),
            Text(
              _optimalDates,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _selectDate(context),
        tooltip: 'Set date range',
        // child: const Text('Set range'),
        label: const Text('Set range'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
