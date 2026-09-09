module Shared.Route (Route(..), route) where

import Prelude hiding ((/))

import Data.Generic.Rep (class Generic)
import Routing.Duplex (RouteDuplex', int, prefix, root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

data Route = AllTodos | SingleTodo Int

derive instance Generic Route _

route :: RouteDuplex' Route
route = root $ prefix "api" $ sum
  { "AllTodos": "todos" / noArgs
  , "SingleTodo": "todos" / int segment
  }
