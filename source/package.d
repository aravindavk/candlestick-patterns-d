module candlestick_patterns;

struct OHLC
{
    string[] date;
    double[] open;
    double[] high;
    double[] low;
    double[] close;

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
            ],
        open:  [100, 105, 100,  80,  90, 110, 100,  70, 100,  90,  60,  90,  60,  70],
        high:  [110, 120, 105, 115, 105, 115, 105, 115, 105, 115, 105, 115, 105, 115],
        low:   [ 90,  80,  85,  75,  85,  75,  85,  75,  85,  75,  85,  75,  85,  75],
        close: [105,  85,  90, 110, 100,  80,  60,  90,  60,  70, 100,  70, 100,  90]
        );

    assert(data.length == 14);
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
}
