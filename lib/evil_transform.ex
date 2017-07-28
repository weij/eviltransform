defmodule EvilTransform do

  alias EvilTransform.Convertor

  defdelegate new_geo(lat, lng), to: Convertor
  defdelegate gcjtowgs(geo), to: Convertor
  defdelegate wgstogcj(geo), to: Convertor
end
