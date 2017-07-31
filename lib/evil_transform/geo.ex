defmodule EvilTransform.Geo do
  @moduledoc """
  This module defines a `EvilTransform.Geo` struct and the main functions
  for working with Plug connections.  
  
  """
  alias EvilTransform.Coordinate

  defstruct(
    lat: 0.0, 
    lng: 0.0,
    dlat: 0.01,
    dlng: 0.01,
    m_coord: %Coordinate{},
    p_coord: %Coordinate{},
    wgs_coord: %Coordinate{},
    gcj_coord: %Coordinate{},
    count: 30
  )
  
  @doc false
  defmacro is_outofchina(lat, lng) do
    quote do
      (is_float(unquote(lng)) and (unquote(lng) < 72.004 or unquote(lng) > 137.8347)) or (is_float(unquote(lat)) and (unquote(lat) < 0.8293 or unquote(lat) > 55.8271))
    end
  end
  
  @doc """
  Return true if given lat/lng within China "square" territory.

  ## Example


    iex> EvilTransform.Geo.outOfChina?(22.596828,114.120043)
    false
    iex> EvilTransform.Geo.outOfChina?(35.652832,139.839478)
    true


  """
  def outOfChina?(lat, lng) when is_outofchina(lat, lng) do
    true
  end
  @doc false
  def outOfChina?(lat, lng) when is_float(lat) and is_float(lng), do: false
  
  @doc """
  Return `{:error, reason}` when latlng is not float number.

  ## Example

    iex> EvilTransform.Geo.outOfChina?(22, 114)
    { :error, "lat/lng must be in float number"}    
    iex> EvilTransform.Geo.outOfChina?("22", "114")
    { :error, "lat/lng must be in float number"}
  """
  def outOfChina?(_lat, _lng), do: { :error, "lat/lng must be in float number"}
end
