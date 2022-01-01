// Utilities for the processing part of the data scrape

class numberCruncher {
  // Convert the date part of a DateTime to midnight UTC
  static DateTime midnightUTC(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

  // Expect an array of [timestamp, value] arrays.
  // Assume timestamps are in ascending order and milliseconds.
  // Return list data normalized to closest UTC midnight
  static List normalizeList(List data) {
    List out = [];
    DateTime t0 = DateTime.fromMillisecondsSinceEpoch(data[0][0], isUtc: true);
    DateTime midnight = midnightUTC(t0);
    if (t0.hour >= 12) {
      // In the PM we're closer to next midnight
      midnight = midnightUTC(t0.add(Duration(days: 1)));
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
        midnight = midnight.add(Duration(days: 1));
        t0 = t;
      }
    }

    return out;
  }

  // How many days is the longest bearish (downward) trend within a given date range?
  // In: List<[DateTime, price]>
  // Out: [DateTime, price]
  static List getBearish(List prices) {
    List bearish = [prices[0][0], 0]; // Start date, duration
    int bearCount = 0;
    int i;
    for (i = 1; i < prices.length; i++) {
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
    return bearish;
  }

  // Which date within a given date range had the highest trading volume?
  // In: List<[DateTime, volume]>
  // Out: [DateTime, volume]
  static List getMaxVolume(List volumes) {
    List maxVolume = volumes[0];
    volumes.forEach((entry) => {
          if (entry[1] > maxVolume[1]) {maxVolume = entry}
        });
    return maxVolume;
  }

  // Optimal days to buy and sell in the date range.
  // In: List<[DateTime, price]> (in ascending order)
  // Out: [DateTime buy, DateTime sell] or [] if entire period is bearish
  static List getOptimalTradeDates(List data) {
    List minPoint = data[0];
    List profitRange = [0, 0];
    num maxProfit = 0;

    for (int i = 1; i < data.length; i++) {
      if (data[i][1] - minPoint[1] > maxProfit) {
        maxProfit = data[i][1] - minPoint[1];
        profitRange = [minPoint[0], data[i][0]];
      }
      if (data[i][1] < minPoint[1]) {
        minPoint = data[i];
      }
    }
    if (profitRange[0] == 0) {
      return [];
    } else {
      return profitRange;
    }
  }
}
