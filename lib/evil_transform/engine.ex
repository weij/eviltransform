defmodule EvilTransform.Engine do
  @moduledoc """
  Core transformation logic - transform and delta.

  """

  @a 6378137.0
  @ee 0.00669342162296594323
  @earthR 6371000.0
  
  @doc """
  Calculate lat/lng deltas according to the given WGS84 lat/lng.

  Return a tuple, which contains lat/lng deltas, respectively.

  ## Example

    iex> EvilTransform.Engine.compute_delta(43.925956,81.304986)
    {0.0012107347458435362, 0.0029884174595647315}
    iex> EvilTransform.Engine.compute_delta(29.337366,120.122021)
    {-0.002467828398120453, 0.004698765444104658}
  """
  def compute_delta(lat, lng) do
    coord = transform(lng - 105.0, lat - 35.0)

    radlat = lat / 180.0 * :math.pi()
    magic  = :math.sin(radlat)
    magic  = 1 - @ee * magic * magic
    sqrtMagic = :math.sqrt(magic)
    dlat = (coord.lat * 180.0) / ((@a * (1 - @ee)) / (magic * sqrtMagic) * :math.pi());
    dlng = (coord.lng * 180.0) / (@a / sqrtMagic * :math.cos(radlat) * :math.pi()); 
    
    { dlat, dlng }
  end

  defp transform(x, y) do
    xy = x * y
    absX = abs(x) |> :math.sqrt()
    d = (20.0 * :math.sin(6.0 * x * :math.pi()) + 20.0 * :math.sin(2.0 * x * :math.pi())) * 2.0 / 3.0

    lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * xy + 0.2 * absX
    lng = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * xy + 0.1 * absX

    lat = lat + d
    lng = lng + d

    lat = lat + (20.0 * :math.sin(y * :math.pi()) + 40.0 * :math.sin(y / 3.0 * :math.pi())) * 2.0 / 3.0
    lng = lng + (20.0 * :math.sin(x * :math.pi()) + 40.0 * :math.sin(x / 3.0 * :math.pi())) * 2.0 / 3.0

    lat = lat + (160.0 * :math.sin(y / 12.0 * :math.pi()) + 320 * :math.sin(y / 30.0 * :math.pi())) * 2.0 / 3.0
    lng = lng + (150.0 * :math.sin(x / 12.0 * :math.pi()) + 300.0 * :math.sin(x / 30.0 * :math.pi())) * 2.0 / 3.0
    
    %{lat: lat, lng: lng}
  end

  @doc """
  Return distance in meter between point(alat, alng) and point(blat, blng).
  """
  def distance(alat, alng, blat, blng) do
    with x = :math.cos( alat * :math.pi / 180 ) * :math.cos( blat * :math.pi / 180 )
        * :math.cos( (alng - blng) * :math.pi / 180 ),
         y = :math.sin( alat * :math.pi / 180 ) * :math.sin( blat * :math.pi / 180 ),
         s = total(x + y),
         alpha = :math.acos(s) do
      alpha * @earthR      
    end
  end

  defp total(s) when s > 1, do: 1
  defp total(s) when s < -1, do: -1
  defp total(s), do: s
end