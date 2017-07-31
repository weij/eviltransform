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
      wgs_coord: %Coordinate{ lat: latitude, lng: longitude },
      out_of_china: Geo.outOfChina?(latitude, longitude)
    } 
  end
  
  # {31.1774276, 121.5272106, 31.17530398364597, 121.531541859215}, // shanghai
  # {22.543847, 113.912316, 22.540796131694766, 113.9171764808363}, // shenzhen
  # {39.911954, 116.377817, 39.91334545536069, 116.38404722455657}
  # %EvilTransform.Pointer{lat: 31.280843281982424, lng: 120.59693001654426}
   # %EvilTransform.Pointer{lat: 30.869473175354003, lng: 105.38519807429383}}
   # %EvilTransform.Pointer{lat: 22.529163670654295, lng: 113.92360864163139}
  # use Geo struct acts as accumulater
  # one function one transform 
  # get low hanging fruits first from main workflow
  # -- gcjtowgs(31.278648,120.601099); -- should return   31.280844,120.596931
  #   -- gcjtowgs(30.867195,105.388889); -- should return    30.869472, 105.385192
  #   -- gcjtowgs(22.52612,113.928469); -- should return     22.529158, 113.923607
  def gcjtowgs(geo = %Geo{count: count}) do
    geo = geo |> do_gcjtowgs(count)
    { geo, geo.wgs_coord |> evil() }
  end
  
   # wgstogcj(31.280844,120.596931); -- should return   31.278648,120.601099 
  def wgstogcj(geo = %Geo{lat: lat, lng: lng}) do
    %{gcj_coord: gcj} = geo = do_wgstogcj(geo, Geo.outOfChina?(lat, lng))
    { geo, evil(gcj) }
  end  

  #############################################################

  def do_wgstogcj(geo, _invalid_latlng = true), do: geo
  def do_wgstogcj(geo = %{wgs_coord: %{lat: lat, lng: lng}}, _valid_latlng) do
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
  
  defp move_wgslat(geo = %{dlat: dlat, p_coord: p, wgs_coord: %{lat: lat}}) when dlat > 0 do
    p_with_new_lat = Map.put(p, :lat, lat)
    Map.put(geo, :p_coord, p_with_new_lat)
  end
  defp move_wgslat(geo = %{m_coord: m, wgs_coord: %{lat: lat}}) do
    m_with_new_lat = Map.put(m, :lat, lat)
    Map.put(geo, :m_coord, m_with_new_lat)    
  end
  defp move_wgslng(geo = %{dlng: dlng, p_coord: p, wgs_coord: %{lng: lng}}) when dlng > 0 do
    p_with_new_lng = Map.put(p, :lng, lng)
    Map.put(geo, :p_coord, p_with_new_lng)
  end
  defp move_wgslng(geo = %{m_coord: m, wgs_coord: %{lng: lng}}) do
    m_with_new_lng = Map.put(m, :lng, lng)
    Map.put(geo, :m_coord, m_with_new_lng)
  end

  defp count_down(geo, by \\ 1) do
    Map.put(geo, :count, geo.count - by)
  end

  defp average_wgs(geo, wgs, m, p) do
    new_wgs = %{ wgs | lat: (m.lat + p.lat) / 2, lng: (m.lng + p.lng) / 2 }
    Map.put(geo, :wgs_coord, new_wgs)
  end

  defp evil(pointer = %Coordinate{}) do
    "#{pointer.lat}, #{pointer.lng}"
  end  

end