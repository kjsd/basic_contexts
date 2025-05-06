defmodule BasicContexts.Utils do
  def random_string(length \\ 32) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  def now_jpn(), do: now_with_timezone("Asia/Tokyo")
  def today_jpn(), do: today_with_timezone("Asia/Tokyo")

  def try_to_date_from(x) when is_binary(x) do
    with {:ok, d} <- Date.from_iso8601(x) do
      d
    else
      _ ->
        nil
    end
  end
  def try_to_date_from(_), do: nil
  
  def try_to_time_from(x) when is_binary(x) do
    with {:ok, d} <- Time.from_iso8601(x) do
      d
    else
      _ ->
        nil
    end
  end
  def try_to_time_from(_), do: nil

  def now_with_timezone(timezone) do
    Calendar.DateTime.now!(timezone)
    |> DateTime.to_naive
    |> NaiveDateTime.truncate(:second)
  end

  def today_with_timezone(timezone), do: Calendar.Date.today!(timezone)

  def now_jpn_datetime() do
    Calendar.DateTime.now!("Asia/Tokyo")
    |> DateTime.truncate(:second)
  end

  def next_date_of_month(%Date{year: y, month: m, day: d}, d1 \\ nil) do
    {year, month} = if m == 12, do: {y + 1, 1}, else: {y, m + 1}

    day = if d1 == nil, do: d, else: d1
    case Date.new(year, month, day) do
      {:ok, v} ->
        v
      {:error, _} ->
        Date.new!(year, month, 1)
        |> Date.end_of_month()
    end
  end

  def next_date_of_year(%Date{year: year, month: month, day: d}, d1 \\ nil) do
    day = if d1 == nil, do: d, else: d1
    case Date.new(year + 1, month, day) do
      {:ok, v} ->
        v
      {:error, _} ->
        Date.new!(year + 1, month, 1)
        |> Date.end_of_month()
    end
  end

  def disjoint?({xs, xe}, {ys, ye}) do
    xs = xs |> Kernel.||(~T[00:00:00])
    ys = ys |> Kernel.||(~T[00:00:00])
    xe = xe |> Kernel.||(~T[23:59:59])
    ye = ye |> Kernel.||(~T[23:59:59])
    
    {xst, _} = Time.to_seconds_after_midnight(xs)
    {xet, _} = Time.to_seconds_after_midnight(xe)
    {yst, _} = Time.to_seconds_after_midnight(ys)
    {yet, _} = Time.to_seconds_after_midnight(ye)

    if xst <= xet and yst <= yet do
      Range.disjoint?(xst..xet, yst..yet)
    else
      true
    end
  end

end
