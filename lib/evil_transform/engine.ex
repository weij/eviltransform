defmodule EvilTransform.Engine do
  
  alias EvilTransform.{Coordinate, Geo}

  @a 6378137.0
  @ee 0.00669342162296594323
  
  def compute_delta(geo = %Geo{}, lat, lng) do
    pointer = transform(lng - 105.0, lat - 35.0)

    radlat = lat / 180.0 * :math.pi()
    magic  = :math.sin(radlat)
    magic  = 1 - @ee * magic * magic
    sqrtMagic = :math.sqrt(magic)
    dlat = (pointer.lat * 180.0) / ((@a * (1 - @ee)) / (magic * sqrtMagic) * :math.pi());
    dlng = (pointer.lng * 180.0) / (@a / sqrtMagic * :math.cos(radlat) * :math.pi()); 

    %{ geo | dlat: dlat, dlng: dlng }
  end

  def transform(x, y) do
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
    
    %Coordinate{lat: lat, lng: lng}
  end

  def addup(geo = %{gcj_pointer: gcj, dlat: dlat, dlng: dlng}, wgslat, wgslng) do
    new_gcj = %{ gcj | lat: wgslat + dlat, lng: wgslng + dlng}
    %{ geo | gcj_pointer: new_gcj }
  end


end