module Main where

import Prelude

import Data.Argonaut
  ( class DecodeJson
  , decodeJson
  , encodeJson
  , parseJson
  , printJsonDecodeError
  , stringify
  )
import Data.Array (filter)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (trim)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, attempt, launchAff_, throwError)
import Effect.Class (liftEffect)
import Effect.Exception (error, message, throw)
import Fetch (Method(..), fetch)
import React.Basic (keyed)
import React.Basic.DOM as R
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.DOM.Events (preventDefault, targetValue)
import React.Basic.Events (handler, handler_)
import React.Basic.Hooks (Component, component, useEffectOnce, useState, useState')
import React.Basic.Hooks as React
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

type Todo = { id :: Int, title :: String, completed :: Boolean }

api :: String
api = "/api/todos"

decodeBody :: forall a. DecodeJson a => String -> Aff a
decodeBody body =
  either (throwError <<< error <<< printJsonDecodeError) pure
    (parseJson body >>= decodeJson)

getTodos :: Aff (Array Todo)
getTodos = do
  { status, text } <- fetch api {}
  body <- text
  case status of
    200 -> decodeBody body
    _ -> throwError $ error $ "一覧の取得に失敗しました (" <> show status <> "): " <> body

addTodo :: String -> Aff (Array Todo -> Array Todo)
addTodo title = do
  { status, text } <- fetch api
    { method: POST
    , headers: { "Content-Type": "application/json" }
    , body: stringify $ encodeJson { title }
    }
  body <- text
  case status of
    201 -> do
      todo <- decodeBody body
      pure (_ <> [ todo ])
    _ -> throwError $ error $ "追加に失敗しました (" <> show status <> "): " <> body

setCompleted :: Todo -> Aff (Array Todo -> Array Todo)
setCompleted todo = do
  { status, text } <- fetch (api <> "/" <> show todo.id)
    { method: PATCH
    , headers: { "Content-Type": "application/json" }
    , body: stringify $ encodeJson { completed: not todo.completed }
    }
  body <- text
  case status of
    200 -> do
      updated <- decodeBody body
      pure $ map \t -> if t.id == updated.id then updated else t
    404 -> throwError $ error "この todo はすでに削除されています"
    _ -> throwError $ error $ "更新に失敗しました (" <> show status <> "): " <> body

deleteTodo :: Int -> Aff (Array Todo -> Array Todo)
deleteTodo id = do
  { status, text } <- fetch (api <> "/" <> show id) { method: DELETE }
  case status of
    204 -> pure $ filter (\t -> t.id /= id)
    404 -> throwError $ error "この todo はすでに削除されています"
    _ -> do
      body <- text
      throwError $ error $ "削除に失敗しました (" <> show status <> "): " <> body

mkApp :: Component Unit
mkApp = component "App" \_ ->
  React.do
    todos /\ setTodos <- useState (Nothing :: Maybe (Array Todo))
    err /\ setErr <- useState' (Nothing :: Maybe String)
    draft /\ setDraft <- useState' ""

    useEffectOnce do
      launchAff_ do
        r <- attempt getTodos
        liftEffect case r of
          Left e -> setErr $ Just $ message e
          Right ts -> setTodos \_ -> Just ts
      pure mempty

    let
      run :: Aff (Array Todo -> Array Todo) -> Effect Unit
      run aff = launchAff_ do
        r <- attempt aff
        liftEffect case r of
          Left e -> setErr $ Just $ message e
          Right f -> setErr Nothing *> setTodos (map f)

      onSubmit = handler preventDefault \_ ->
        case trim draft of
          "" -> pure unit
          title -> do
            run $ addTodo title
            setDraft ""

      row todo = keyed (show todo.id) $ R.li_
        [ R.input
            { type: "checkbox"
            , checked: todo.completed
            , onChange: handler_ $ run $ setCompleted todo
            }
        , R.text todo.title
        , R.button
            { onClick: handler_ $ run $ deleteTodo todo.id
            , children: [ R.text "削除" ]
            }
        ]

      errView = case err of
        Nothing -> R.text ""
        Just msg -> R.p_ [ R.text msg ]

      listView = case todos of
        Nothing -> R.text "Loading..."
        Just ts -> R.ul_ (map row ts)

    pure $ R.div_
      [ R.h1_ [ R.text "todo" ]
      , R.form
          { onSubmit
          , children:
              [ R.input
                  { value: draft
                  , onChange: handler targetValue (setDraft <<< fromMaybe "")
                  }
              , R.button { type: "submit", children: [ R.text "追加" ] }
              ]
          }
      , errView
      , listView
      ]

main :: Effect Unit
main = do
  app <- mkApp
  doc <- document =<< window
  root <- getElementById "root" $ toNonElementParentNode doc
  case root of
    Nothing -> throw "Could not find container element"
    Just container -> do
      reactRoot <- createRoot container
      renderRoot reactRoot $ app unit
