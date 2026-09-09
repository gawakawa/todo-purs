module Backend.Todo.Handler
  ( createTodo
  , deleteTodo
  , listTodos
  , setCompleted
  ) where

import Prelude

import Backend.Db (query)
import Backend.Error (ApiError(..), Handler)
import Backend.Todo (decodeTodo, validateTitle)
import Control.Monad.Except (except, throwError)
import Control.Monad.Trans.Class (lift)
import Data.Argonaut (encodeJson)
import Data.Array (head, null)
import Data.Bifunctor (lmap)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect.Exception (message)
import Shared.Todo
  ( CreateTodoRequest
  , CreateTodoResponse
  , DeleteTodoRequest
  , DeleteTodoResponse
  , ListTodosRequest
  , ListTodosResponse
  , SetCompletedRequest
  , SetCompletedResponse
  )

listTodos :: ListTodosRequest -> Handler ListTodosResponse
listTodos _ = do
  rows <- lift $ query "SELECT id, title, completed FROM todos ORDER BY id" []
  except $ lmap (ServerError <<< message) $ traverse decodeTodo rows

createTodo :: CreateTodoRequest -> Handler CreateTodoResponse
createTodo { title } = do
  valid <- except $ lmap (BadRequest <<< message) $ validateTitle title
  rows <- lift $ query
    "INSERT INTO todos (title) VALUES (?) RETURNING id, title, completed"
    [ encodeJson valid ]
  case head rows of
    Nothing -> throwError $ ServerError "insert returned no row"
    Just row -> except $ lmap (ServerError <<< message) $ decodeTodo row

setCompleted :: SetCompletedRequest -> Handler SetCompletedResponse
setCompleted { id, completed } = do
  rows <- lift $ query
    "UPDATE todos SET completed = ? WHERE id = ? RETURNING id, title, completed"
    [ encodeJson (if completed then 1 else 0), encodeJson id ]
  case head rows of
    Nothing -> throwError NotFound
    Just row -> except $ lmap (ServerError <<< message) $ decodeTodo row

deleteTodo :: DeleteTodoRequest -> Handler DeleteTodoResponse
deleteTodo { id } = do
  rows <- lift $ query "DELETE FROM todos WHERE id = ? RETURNING id"
    [ encodeJson id ]
  when (null rows) $ throwError NotFound
