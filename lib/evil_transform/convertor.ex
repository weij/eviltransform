defmodule EvilTransform.Convertor do
  
  alias EvilTransform.{Coordinate, Engine, Geo}

  @initDelta 0.01
  @threshold 0.000001

  def new_geo(latitude, longitude) 
    when is_float(latitude) and is_float(longitude) do

    %Geo{
      lat: latitude, 
      lng: longitude,
      dlat: @initDelta, 
      dlng: @initDelta,
      m_coord: %Coordinate{ lat: latitude - @initDelta, lng: longitude - @initDelta },
      p_coord: %Coordinate{ lat: latitude + @initDelta, lng: longitude + @initDelta },
      wgs_coord: %Coordinate{ lat: latitude, lng: longitude }
    } 
  end

  @doc """
  Convert GCJ-02 coordinate to WGS-84 coordinate.

  ## Example

    iex> geo = EvilTransform.Convertor.new_geo(22.59414209,114.1251447)
    iex> EvilTransform.gcjtowgs(geo)
    { %EvilTransform.Geo{...}, "22.59682824722656, 114.12004399199218" }

    iex> EvilTransform.Convertor.new_geo(39.061111,121.787113) |> EvilTransform.gcjtowgs()
    { %EvilTransform.Geo{...}, "39.06008011621094, 121.78199886425783" }
  """
  def gcjtowgs(geo = %Geo{count: count}) do
    new_geo = do_gcjtowgs(geo, count)
    { new_geo, evil(new_geo.wgs_coord) }
  end

  @doc """
  Convert WGS-84 coordinate to GCJ-02 coordinate.
  
  ## Example

    iex> geo = EvilTransform.Convertor.new_geo(31.280844,120.596931)
    iex> EvilTransform.Convertor.wgstogcj(geo)
    { %Geo{}, "31.278648624428175, 120.60109998322247" }
  """
  def wgstogcj(geo = %Geo{lat: lat, lng: lng}) do
    case do_wgstogcj(geo, Geo.outOfChina?(lat, lng)) do
      { geo, :outOfChina } ->
        { geo, "Error: lat/lng out of China"}
      geo = %{gcj_coord: gcj} ->
        { geo, evil(gcj) }
    end    
  end  

  #############################################################

  def do_wgstogcj(geo = %Geo{}, _invalid_latlng = true), do: { geo, :outOfChina }
  def do_wgstogcj(geo = %Geo{wgs_coord: %{lat: lat, lng: lng}}, _valid_latlng) do
    {dlat, dlng} = Engine.compute_delta(lat, lng) 
    %{ geo | gcj_coord: %Coordinate{ lat: lat + dlat, lng: lng + dlng } }
  end
  
  def do_gcjtowgs(geo = %Geo{dlat: dlat, dlng: dlng},  _) when abs(dlat) < @threshold and abs(dlng) < @threshold, do: geo
  def do_gcjtowgs(geo = %Geo{}, count) when count < 1, do: geo
  def do_gcjtowgs(geo = %Geo{wgs_coord: wgs, m_coord: m, p_coord: p}, count) when count >= 1 do
    
    new_geo = 
      geo
      |> average_wgs(wgs, m, p)
      |> do_wgstogcj(_not_outofchina = false)
      |> new_delta_from_gcj()
      |> move_wgslat()
      |> move_wgslng()
      |> count_down() 

    do_gcjtowgs(
      new_geo, 
      new_geo.count
    )
  end

  defp new_delta_from_gcj(geo = %Geo{gcj_coord: gcj, lat: lat, lng: lng}) do
    %{ geo | dlat: gcj.lat - lat, dlng: gcj.lng - lng}
  end
  
  defp move_wgslat(geo = %Geo{dlat: dlat, p_coord: p, wgs_coord: %{lat: lat}}) when dlat > 0 do
    p_with_new_lat = Map.put(p, :lat, lat)
    Map.put(geo, :p_coord, p_with_new_lat)
  end
  defp move_wgslat(geo = %Geo{m_coord: m, wgs_coord: %{lat: lat}}) do
    m_with_new_lat = Map.put(m, :lat, lat)
    Map.put(geo, :m_coord, m_with_new_lat)    
  end
  defp move_wgslng(geo = %Geo{dlng: dlng, p_coord: p, wgs_coord: %{lng: lng}}) when dlng > 0 do
    p_with_new_lng = Map.put(p, :lng, lng)
    Map.put(geo, :p_coord, p_with_new_lng)
  end
  defp move_wgslng(geo = %Geo{m_coord: m, wgs_coord: %{lng: lng}}) do
    m_with_new_lng = Map.put(m, :lng, lng)
    Map.put(geo, :m_coord, m_with_new_lng)
  end

  defp count_down(geo = %Geo{}, by \\ 1) do
    Map.put(geo, :count, geo.count - by)
  end

  defp average_wgs(geo = %Geo{}, wgs, m, p) do
    new_wgs = %{ wgs | lat: (m.lat + p.lat) / 2, lng: (m.lng + p.lng) / 2 }
    Map.put(geo, :wgs_coord, new_wgs)
  end

  defp evil(pointer = %Coordinate{}) do
    "#{pointer.lat}, #{pointer.lng}"
  end  

end