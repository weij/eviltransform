defmodule EvilTransform.Geo do

  alias EvilTransform.Pointer

  defstruct(
    lat: 0.0, 
    lng: 0.0,
    dlat: 0.01,
    dlng: 0.01,
    m_pointer: %Pointer{},
    p_pointer: %Pointer{},
    wgs_pointer: %Pointer{},
    gcj_pointer: %Pointer{},
    count: 30,
    out_of_china: true
  )

  defmacro is_outofchina(lat, lng) do
    quote do
      (is_float(unquote(lng)) and (unquote(lng) < 72.004 or unquote(lng) > 137.8347)) or (is_float(unquote(lat)) and (unquote(lat) < 0.8293 or unquote(lat) > 55.8271))
    end
  end

  def outOfChina?(lat, lng) when is_outofchina(lat, lng) do
    true
  end

  def outOfChina?(lat, lng) when is_float(lat) and is_float(lng), do: false
  def outOfChina?(_lat, _lng), do: { :error, "input lat/lng required in float number"}
end
