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
}

unittest
{
    auto data = OHLC(
        date: ["d1", "d2"],
        open: [100, 105],
        high: [110, 120],
        low: [90, 80],
        close: [105, 85]
        );
    assert(data.length == 2);
    assert(data.isGreen(0));
    assert(data.isRed(1));
    assert(data.isWhite(0));
    assert(data.isBlack(1));
}
