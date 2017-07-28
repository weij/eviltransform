defmodule EvilTransform do

  alias EvilTransform.Convertor
  alias EvilTransform.Convertor2

  defdelegate new_geo(lat, lng), to: Convertor
  defdelegate gcjtowgs(geo), to: Convertor
  defdelegate( wgstogcj(geo), to: Convertor )
  defdelegate new_geo2(lat, lng), to: Convertor2, as: :new_geo
  defdelegate gcjtowgs2(geo), to: Convertor2, as: :gcjtowgs
end
