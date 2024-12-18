module candlestick_patterns;

struct Candle
{
    string date;
    double open;
    double high;
    double low;
    double close;
}

struct OHLC
{
    string[] date;
    double[] open;
    double[] high;
    double[] low;
    double[] close;

    static OHLC fromCandles(Candle[] candles)
    {
        OHLC data;
        foreach(candle; candles)
        {
            data.date ~= candle.date;
            data.open ~= candle.open;
            data.high ~= candle.high;
            data.low ~= candle.low;
            data.close ~= candle.close;
        }
        return data;
    }

    size_t length()
    {
        return date.length;
    }

    bool isGreen(size_t idx)
    {
        return close[idx] > open[idx];
    }

    bool isWhite(size_t idx)
    {
        return isGreen(idx);
    }

    bool isRed(size_t idx)
    {
        return close[idx] < open[idx];
    }

    bool isBlack(size_t idx)
    {
        return isRed(idx);
    }

    bool isBullishEngulfing(size_t currentIdx)
    {
        if (currentIdx <= 0)
            return false;

        auto prevIdx = currentIdx - 1;

        // Prev candle is Red
        // Current candle is Green
        // Current candle close covers the prev open
        // Current candle open covers the prev close
        //      |
        //  |  | |
        // ||| | |
        // ||| | |
        //  |  | |
        //      |
        if (isRed(prevIdx) && isGreen(currentIdx) && close[currentIdx] > open[prevIdx] && open[currentIdx] < close[prevIdx])
            return true;

        return false;
    }

    bool isBearishEngulfing(size_t currentIdx)
    {
        if (currentIdx <= 0)
            return false;

        auto prevIdx = currentIdx - 1;

        // Prev candle is Green
        // Current candle is Red
        // Current candle open covers the prev close
        // Current candle close covers the prev open
        //      |
        //  |  |||
        // | | |||
        // | | |||
        //  |  |||
        //      |
        if (isGreen(prevIdx) && isRed(currentIdx) && open[currentIdx] > close[prevIdx] && close[currentIdx] < open[prevIdx])
            return true;

        return false;
    }

    bool isBullishHarami(size_t currentIdx)
    {
        if (currentIdx <= 0)
            return false;

        auto prevIdx = currentIdx - 1;

        // Prev candle is Red
        // Current candle is Green/Red
        // Current candle body is contained within the previous candle body
        //  |
        // |||  |
        // ||| | |
        // ||| | |
        // |||  |
        //  |
        if (isRed(prevIdx))
        {
            if (isGreen(currentIdx) && close[currentIdx] < open[prevIdx] && open[currentIdx] > close[prevIdx])
                return true;

            if (isRed(currentIdx) && open[currentIdx] < open[prevIdx] && close[currentIdx] > close[prevIdx])
                return true;
        }

        return false;
    }

    bool isBearishHarami(size_t currentIdx)
    {
        if (currentIdx <= 0)
            return false;

        auto prevIdx = currentIdx - 1;

        // Prev candle is Green
        // Current candle is Green/Red
        // Current candle body is contained within the previous candle body
        //  |
        // | |  |
        // | | | |
        // | | | |
        // | |  |
        //  |
        if (isGreen(prevIdx))
        {
            if (isGreen(currentIdx) && open[currentIdx] > open[prevIdx] && close[currentIdx] < close[prevIdx])
                return true;

            if (isRed(currentIdx) && open[currentIdx] < close[prevIdx] && close[currentIdx] > open[prevIdx])
                return true;
        }

        return false;
    }

    bool isDarkCloudCover(size_t currentIdx)
    {
        if (currentIdx <= 0)
            return false;

        auto prevIdx = currentIdx - 1;

        // Prev candle is Green
        // Current candle is Red
        // Current candle opens above the previous close but closes between prev open and close
        //      |
        //  |  |||
        // | | |||
        // | | |||
        // | |  |
        //  |
        if (isGreen(prevIdx) && isRed(currentIdx) && open[currentIdx] > close[prevIdx] && open[prevIdx] < close[currentIdx] && close[currentIdx] < close[prevIdx])
            return true;

        return false;
    }

    bool isPiercing(size_t currentIdx)
    {
        if (currentIdx <= 0)
            return false;

        auto prevIdx = currentIdx - 1;

        // Prev candle is Red
        // Current candle is Green
        // Current candle opens below the previous close but closes between prev open and close
        //  |
        // |||  |
        // ||| | |
        // ||| | |
        //  |  | |
        //      |
        if (isRed(prevIdx) && isGreen(currentIdx) && open[currentIdx] < close[prevIdx] && open[prevIdx] > close[currentIdx] && close[currentIdx] > close[prevIdx])
            return true;

        return false;
    }

    bool isBullishMarubozu(size_t idx)
    {
        if (isRed(idx)) return false;

        auto highPct = (high[idx] - close[idx]) * 100.0 / close[idx];
        auto lowPct = (open[idx] - low[idx]) * 100.0 / open[idx];

        // If the gap between high and close is zero or negligible difference
        // and same for the gap between open and low.
        //
        //  | |
        //  | |
        //  | |
        //
        return highPct < 0.3 && lowPct < 0.3;
    }

    bool isBearishMarubozu(size_t idx)
    {
        if (isGreen(idx)) return false;

        auto highPct = (high[idx] - open[idx]) * 100.0 / open[idx];
        auto lowPct = (close[idx] - low[idx]) * 100.0 / close[idx];

        // If the gap between high and close is zero or negligible difference
        // and same for the gap between open and low.
        //
        //  |||
        //  |||
        //  |||
        //
        return highPct < 0.3 && lowPct < 0.3;
    }
}

unittest
{
    auto data = OHLC(
        date: [
            "d1",         // Green Candle
            "d2",         // Red Candle
            "d3", "d4",   // Bullish Engulfing
            "d5", "d6",   // Bearish Engulfing
            "d7", "d8",   // Bullish Harami (Green second candle)
            "d9", "d10",  // Bullish Harami (Red second candle)
            "d11", "d12", // Bearish Harami (Green second candle)
            "d13", "d14", // Bearish Harami (Red second candle)
            "d15", "d16", // Dark Cloud Cover
            "d17", "d18", // Piercing
            "d19",        // Bullish Marubozu
            "d20",        // Bearish Marubozu
            ],
        open:  [100, 105, 100,  80,  90, 110, 100,  70, 100,  90,  60,  90,  60,  70,  60, 100, 100,  60, 100, 110],
        high:  [110, 120, 105, 115, 105, 115, 105, 115, 105, 115, 105, 115, 105, 115, 100, 110, 110, 100, 110, 110],
        low:   [ 90,  80,  85,  75,  85,  75,  85,  75,  85,  75,  85,  75,  85,  75,  80,  60,  60,  55, 100, 100],
        close: [105,  85,  90, 110, 100,  80,  60,  90,  60,  70, 100,  70, 100,  90,  90,  70,  70,  90, 110, 100]
        );

    assert(data.length == 20);
    assert(data.isGreen(0));
    assert(data.isRed(1));
    assert(data.isWhite(0));
    assert(data.isBlack(1));
    assert(data.isBullishEngulfing(3));
    assert(data.isBearishEngulfing(5));
    assert(data.isBullishHarami(7));
    assert(data.isBullishHarami(9));
    assert(data.isBearishHarami(11));
    assert(data.isBearishHarami(13));
    assert(data.isDarkCloudCover(15));
    assert(data.isPiercing(17));
    assert(data.isBullishMarubozu(18));
    assert(data.isBearishMarubozu(19));

    auto data1 = OHLC.fromCandles([Candle("d1", 100, 110, 90, 105), Candle("d2", 105, 120, 80, 85)]);
    assert(data1.length == 2);
    assert(data1.isGreen(0));
    assert(data1.isRed(1));
}
