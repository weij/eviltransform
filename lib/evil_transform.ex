defmodule EvilTransform do

  alias EvilTransform.Convertor
  
  @doc """
  Build a Geo struct according to given latitude and longitude.
  """
  defdelegate new_geo(lat, lng), to: Convertor

  @doc """
  Convert GCJ-02 coordinate to WGS-84 coordinate.

  accurate rate within 1km.
  """
  defdelegate gcjtowgs(geo), to: Convertor

  @doc """
  Convert WGS-84 coordinate to GCJ-02 coordinate.

  accurate rate within 5m.
  """
  defdelegate wgstogcj(geo), to: Convertor
end
