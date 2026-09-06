module Api (fetchTodos, createTodo, updateCompleted, deleteTodo) where

import Prelude

import Data.Argonaut
  ( class DecodeJson
  , decodeJson
  , encodeJson
  , parseJson
  , printJsonDecodeError
  , stringify
  )
import Data.Either (either)
import Effect.Aff (Aff, throwError)
import Effect.Exception (error)
import Fetch (Method(..), fetch)
import Todo (Todo)

data Route = AllTodos | SingleTodo Int

path :: Route -> String
path AllTodos = "/api/todos"
path (SingleTodo id) = path AllTodos <> "/" <> show id

decodeBody :: forall a. DecodeJson a => String -> Aff a
decodeBody body =
  either (throwError <<< error <<< printJsonDecodeError) pure
    (parseJson body >>= decodeJson)

fetchTodos :: Aff (Array Todo)
fetchTodos = do
  { status, text } <- fetch (path AllTodos) {}
  body <- text
  case status of
    200 -> decodeBody body
    _ -> throwError $ error $ "一覧の取得に失敗しました (" <> show status <> "): " <> body

createTodo :: String -> Aff Todo
createTodo title = do
  { status, text } <- fetch (path AllTodos)
    { method: POST
    , headers: { "Content-Type": "application/json" }
    , body: stringify $ encodeJson { title }
    }
  body <- text
  case status of
    201 -> decodeBody body
    _ -> throwError $ error $ "追加に失敗しました (" <> show status <> "): " <> body

updateCompleted :: Int -> Boolean -> Aff Todo
updateCompleted id completed = do
  { status, text } <- fetch (path (SingleTodo id))
    { method: PATCH
    , headers: { "Content-Type": "application/json" }
    , body: stringify $ encodeJson { completed }
    }
  body <- text
  case status of
    200 -> decodeBody body
    404 -> throwError $ error "この todo はすでに削除されています"
    _ -> throwError $ error $ "更新に失敗しました (" <> show status <> "): " <> body

deleteTodo :: Int -> Aff Unit
deleteTodo id = do
  { status, text } <- fetch (path (SingleTodo id)) { method: DELETE }
  case status of
    204 -> pure unit
    404 -> throwError $ error "この todo はすでに削除されています"
    _ -> do
      body <- text
      throwError $ error $ "削除に失敗しました (" <> show status <> "): " <> body
