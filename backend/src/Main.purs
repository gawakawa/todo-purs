module Main where

import Prelude hiding ((/))

import Control.Monad.Trans.Class (lift)
import Data.Argonaut (class EncodeJson, encodeJson, printJsonDecodeError)
import Data.Array (head, null)
import Data.Either (either)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Db (query)
import Effect.Aff.Class (class MonadAff)
import Effect.Exception (message)
import HTTPurple
  ( ClosingHandler(..)
  , Method(..)
  , Request
  , Response
  , ResponseM
  , RouteDuplex'
  , ServerM
  , badRequest
  , fromValidatedE
  , int
  , internalServerError
  , jsonHeaders
  , methodNotAllowed
  , noArgs
  , noContent
  , notFound
  , ok'
  , prefix
  , response'
  , root
  , segment
  , serve
  , sum
  , toJson
  , usingCont
  , (/)
  )
import HTTPurple.Json (fromJsonE)
import HTTPurple.Json.Argonaut as Argonaut
import HTTPurple.Status as Status
import Todo (NewTodo, TodoPatch, decodeTodo, validateTitle)

data Route = AllTodos | SingleTodo Int

derive instance Generic Route _

route :: RouteDuplex' Route
route = root $ prefix "api" $ sum
  { "AllTodos": "todos" / noArgs
  , "SingleTodo": "todos" / int segment
  }

main :: ServerM
main =
  serve { port: 8080, closingHandler: NoClosingHandler } { route, router }

router :: Request Route -> ResponseM
router { route: AllTodos, method: Get } = do
  rows <- query "SELECT id, title, completed FROM todos ORDER BY id" []
  either (internalServerError <<< message) jsonOk $ traverse decodeTodo rows

router { route: AllTodos, method: Post, body } = usingCont do
  { title } :: NewTodo <- fromJsonE Argonaut.jsonDecoder
    (badRequest <<< printJsonDecodeError)
    body
  valid <- fromValidatedE validateTitle (badRequest <<< message) title
  rows <- lift $ query
    "INSERT INTO todos (title) VALUES (?) RETURNING id, title, completed"
    [ encodeJson valid ]
  case head rows of
    Nothing -> internalServerError "insert returned no row"
    Just row -> either (internalServerError <<< message) jsonCreated $
      decodeTodo row

router { route: AllTodos } = methodNotAllowed

router { route: SingleTodo id, method: Patch, body } = usingCont do
  { completed } :: TodoPatch <- fromJsonE Argonaut.jsonDecoder
    (badRequest <<< printJsonDecodeError)
    body
  rows <- lift $ query
    "UPDATE todos SET completed = ? WHERE id = ? RETURNING id, title, completed"
    [ encodeJson (if completed then 1 else 0), encodeJson id ]
  case head rows of
    Nothing -> notFound
    Just row -> either (internalServerError <<< message) jsonOk $ decodeTodo row

router { route: SingleTodo id, method: Delete } = do
  rows <- query "DELETE FROM todos WHERE id = ? RETURNING id" [ encodeJson id ]
  if null rows then notFound else noContent

router { route: SingleTodo _ } = methodNotAllowed

jsonOk :: forall m a. MonadAff m => EncodeJson a => a -> m Response
jsonOk = ok' jsonHeaders <<< toJson Argonaut.jsonEncoder

jsonCreated :: forall m a. MonadAff m => EncodeJson a => a -> m Response
jsonCreated = response' Status.created jsonHeaders <<< toJson
  Argonaut.jsonEncoder
