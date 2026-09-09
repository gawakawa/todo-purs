module Backend.Router (router) where

import Prelude

import Backend.Response (respond)
import Backend.Todo.Handler (createTodo, deleteTodo, listTodos, setCompleted)
import Data.Argonaut (printJsonDecodeError)
import HTTPurple
  ( Method(..)
  , Request
  , ResponseM
  , badRequest
  , jsonHeaders
  , methodNotAllowed
  , noContent
  , ok'
  , response'
  , toJson
  , usingCont
  )
import HTTPurple.Json (fromJsonE)
import HTTPurple.Json.Argonaut as Argonaut
import HTTPurple.Status as Status
import Shared.Route (Route(..))
import Shared.Todo (CreateTodoRequest, SetCompletedBody)

router :: Request Route -> ResponseM
router { route: AllTodos, method: Get } =
  respond (ok' jsonHeaders <<< toJson Argonaut.jsonEncoder) (listTodos {})

router { route: AllTodos, method: Post, body } = usingCont do
  req :: CreateTodoRequest <- fromJsonE Argonaut.jsonDecoder
    (badRequest <<< printJsonDecodeError)
    body
  respond
    (response' Status.created jsonHeaders <<< toJson Argonaut.jsonEncoder)
    (createTodo req)

router { route: AllTodos } = methodNotAllowed

router { route: SingleTodo id, method: Patch, body } = usingCont do
  b :: SetCompletedBody <- fromJsonE Argonaut.jsonDecoder
    (badRequest <<< printJsonDecodeError)
    body
  respond (ok' jsonHeaders <<< toJson Argonaut.jsonEncoder)
    (setCompleted { id, completed: b.completed })

router { route: SingleTodo id, method: Delete } =
  respond (const noContent) (deleteTodo { id })

router { route: SingleTodo _ } = methodNotAllowed
