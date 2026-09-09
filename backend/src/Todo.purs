module Backend.Todo (decodeTodo, validateTitle) where

import Prelude

import Data.Argonaut (Json, JsonDecodeError, decodeJson, printJsonDecodeError)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.String (trim)
import Effect.Exception (Error, error)
import Shared.Todo (Todo)

type TodoRow = { id :: Int, title :: String, completed :: Int }

fromRow :: TodoRow -> Todo
fromRow { id, title, completed } = { id, title, completed: completed /= 0 }

decodeTodo :: Json -> Either Error Todo
decodeTodo json = fromRow <$> lmap decodeError (decodeJson json)
  where
  decodeError :: JsonDecodeError -> Error
  decodeError = error <<< printJsonDecodeError

validateTitle :: String -> Either Error String
validateTitle title = case trim title of
  "" -> Left $ error "title must not be empty"
  trimmed -> Right trimmed
