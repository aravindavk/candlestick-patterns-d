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
}

unittest
{
    auto data = OHLC(
        date: ["d1", "d2", "d3", "d4", "d5", "d6"],
        open: [100, 105, 100, 80, 90, 110],
        high: [110, 120, 105, 115, 105, 115],
        low: [90, 80, 85, 75, 85, 75],
        close: [105, 85, 90, 110, 100, 80]
        );

    assert(data.length == 6);
    assert(data.isGreen(0));
    assert(data.isRed(1));
    assert(data.isWhite(0));
    assert(data.isBlack(1));
    assert(data.isBullishEngulfing(3));
    assert(data.isBearishEngulfing(5));
}
