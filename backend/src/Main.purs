module Main where

import HTTPurple
import Prelude hiding ((/))

import Data.Argonaut.Core (fromArray, stringify)
import Data.Generic.Rep (NoArguments)
import Db (query)

route :: RouteDuplex' NoArguments
route = root $ path "api/todos" noArgs

main :: ServerM
main =
  serve { port: 8080, closingHandler: NoClosingHandler } { route, router }
  where
  router _ = do
    rows <- query "SELECT id, title FROM todos ORDER BY id" []
    ok' jsonHeaders $ stringify $ fromArray rows
