module Yaml.Extra exposing (andMap)

import Yaml.Decode as Yaml


andMap : Yaml.Decoder a -> Yaml.Decoder (a -> b) -> Yaml.Decoder b
andMap =
    Yaml.map2 (\a f -> f a)
