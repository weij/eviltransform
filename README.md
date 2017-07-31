# EvilTransform

**Transform coordinate between earth(WGS-84) and mars in china(GCJ-02)**

```elixir
  geo = EvilTransform.new_geo(31.278648,120.601099)
  EvilTransform.gcjtowgs(geo)

  # or 

  EvilTransform.new_geo(31.278648,120.601099) |> EvilTransform.gcjtowgs()

```

## Installation

Add `evil_transform` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:evil_transform, "~> 0.2.0"}
  ]
end
```

Documentation can
be found at [https://hexdocs.pm/evil_transform](https://hexdocs.pm/evil_transform).

## ToDo List

 - bd09ll to gcj-02
 - bd09ll to wgs-84

## Algorithm Sources:

 - https://on4wp7.codeplex.com/SourceControl/changeset/view/21483#353936
 - http://emq.googlecode.com/svn/emq/src/Algorithm/Coords/Converter.java

## References:

 - https://github.com/googollee/eviltransform
 - http://blog.csdn.net/coolypf/article/details/8686588
 - http://cxzy.people.com.cn/GB/196034/14908095.html


