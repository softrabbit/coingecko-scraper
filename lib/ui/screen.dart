import 'package:flutter/material.dart';
import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTimeRange? _when = null;
  String _dateRange = "Press the button to set date range.";
  String _bearish = "";
  String _highestVolume = "";
  String _optimalDates = "";

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
      setState(() {
        _when = pickedRange;
        _dateRange =
            _toDateString(_when!.start) + " - " + _toDateString(_when!.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_dateRange',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              '$_bearish',
            ),
            Text(
              '$_highestVolume',
            ),
            Text(
              '$_optimalDates',
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
