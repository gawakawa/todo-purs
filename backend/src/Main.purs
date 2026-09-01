module Main where

import HTTPurple
import Prelude hiding ((/))

data Route = Hello String

derive instance Generic Route _

route :: RouteDuplex' Route
route = mkRoute
  { "Hello": "api" / "hello" / segment
  }

main :: ServerM
main =
  serve { port: 8080 } { route, router }
  where
  router { route: Hello name } = ok $ "hello " <> name
