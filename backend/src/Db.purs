module Db (query) where

import Control.Promise (Promise, toAffE)
import Data.Argonaut.Core (Json)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import queryImpl
  :: String -> Array Json -> Effect (Promise (Array Json))

query :: String -> Array Json -> Aff (Array Json)
query sql params = toAffE (queryImpl sql params)
