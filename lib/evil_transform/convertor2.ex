defmodule EvilTransform.Convertor2 do
 
  alias EvilTransform.{Geo, Pointer, Transform}

  @initDelta 0.01
  @threshold 0.000001

  def new_geo(latitude, longitude) 
    when is_float(latitude) and is_float(longitude) do

    %Geo{
      lat: latitude, 
      lng: longitude,
      dlat: @initDelta, 
      dlng: @initDelta,
      m_pointer: %Pointer{ lat: latitude - @initDelta, lng: longitude - @initDelta },
      p_pointer: %Pointer{ lat: latitude + @initDelta, lng: longitude + @initDelta },
      out_of_china: Geo.outOfChina?(latitude, longitude)
    } 
  end
  
  # Geo struct acts as accumulater
  # one function one transform 
  # get low hanging fruits first from main workflow
  # -- gcjtowgs(31.278648,120.601099); -- should return   31.280844,120.596931
  #   -- gcjtowgs(30.867195,105.388889); -- should return    30.869472 |     105.385192 |
  #   -- gcjtowgs(22.52612,113.928469); -- should return     22.529158 |     113.923607 |
  def gcjtowgs(geo = %Geo{}) do
    geo = do_gcjtowgs(geo, geo.wgs_pointer, geo.m_pointer, geo.p_pointer, geo.count)
    {geo, geo.wgs_pointer}
  end
  
  def wgstogcj(geo = %Geo{}) do
    geo = do_wgstogcj(geo, geo.out_of_china)
    {geo, geo.gcj_pointer}
  end

  def do_wgstogcj(geo, _invalid_latlng = true), do: geo
  def do_wgstogcj(geo, _valid_latlng) do
    geo 
    |> Transform.compute_delta(geo.wgs_pointer.lat, geo.wgs_pointer.lng) 
    |> Transform.addup(geo.wgs_pointer.lat, geo.wgs_pointer.lng)
  end

  def do_gcjtowgs(geo = %Geo{dlat: dlat, dlng: dlng}, _, _, _, _) 
    when abs(dlat) < @threshold and abs(dlng) < @threshold do
    geo
  end

  def do_gcjtowgs(geo = %Geo{}, wgs, m, p, count) when count < 1 do
    %{ geo | wgs_pointer: wgs, m_pointer: m, p_pointer: p }
  end

  def do_gcjtowgs(geo = %Geo{}, wgs, m, p, count) when count >= 1 do
    new_wgs = average_wgs(wgs, m, p)

    {geo, gcj_pointer} = Map.put(geo, :wgs_pointer, new_wgs) |> wgstogcj()

    new_dlat = gcj_pointer.lat - geo.lat 
    new_dlng = gcj_pointer.lng - geo.lng
    
    new_geo = 
      geo
      |> move_wgslat(new_wgs, m, p, new_dlat)
      |> move_wgslng(new_wgs, m, p, new_dlng)
      |> count_down()

    do_gcjtowgs(
      new_geo, 
      new_geo.wgs_pointer, 
      new_geo.m_pointer, 
      new_geo.p_pointer, 
      new_geo.count
    )
  end
  
  defp count_down(geo, by \\ 1) do
    Map.put(geo, :count, geo.count - by)
  end

  defp average_wgs(wgs, m, p) do
    %{ wgs | lat: (m.lat + p.lat) / 2, lng: (m.lng + p.lng) / 2 }
  end

  defp move_wgslat(geo, wgs, _m, p, dlat) when dlat > 0 do
    new_p = Map.put(p, :lat, wgs.lat)
    Map.put(geo, :p_pointer, new_p)
  end
  defp move_wgslat(geo, wgs, m, _p, _dlat) do
    new_m = Map.put(m, :lat, wgs.lat)
    Map.put(geo, :m_pointer, new_m)
  end

  defp move_wgslng(geo, wgs, _m, p, dlng) when dlng > 0 do
    new_p = Map.put(p, :lng, wgs.lng)
    Map.put(geo, :p_pointer, new_p)
  end
  defp move_wgslng(geo, wgs, m, _p, _dlng) do
    new_m = Map.put(m, :lng, wgs.lng)
    Map.put(geo, :m_pointer, new_m)
  end  
  
end