module Main where

import Backend.Router (router)
import HTTPurple (ClosingHandler(..), ServerM, serve)
import Shared.Route (route)

main :: ServerM
main =
  serve { port: 8080, closingHandler: NoClosingHandler } { route, router }
