defmodule EvilTransform do
  @moduledoc """
  EvilTransform Public API.
  
  """

  alias EvilTransform.{Convertor, Engine}
  
  @doc """
  Build a Geo struct according to given latitude and longitude.
  """
  defdelegate new_geo(lat, lng), to: Convertor

  @doc """
  Convert GCJ-02 coordinate to WGS-84 coordinate.

  accurate rate within 10m.
  """
  defdelegate gcjtowgs(geo), to: Convertor

  @doc """
  Convert WGS-84 coordinate to GCJ-02 coordinate.

  accurate rate within 5m.
  """
  defdelegate wgstogcj(geo), to: Convertor
  
  @doc """
  Return distance in meter between point(alat, alng) and point(blat, blng).
  """
  defdelegate distance(alat, alng, blat, blng), to: Engine
end
