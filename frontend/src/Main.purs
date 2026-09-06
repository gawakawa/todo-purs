module Main where

import Prelude

import Api (createTodo, deleteTodo, fetchTodos, updateCompleted)
import Data.Array (filter)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, attempt, launchAff_)
import Effect.Class (liftEffect)
import Effect.Exception (message, throw)
import React.Basic (keyed)
import React.Basic.DOM as R
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Hooks (Component, component, useEffectOnce, useState, useState')
import React.Basic.Hooks as React
import Todo (Todo)
import TodoForm (mkTodoForm)
import TodoItem (mkTodoItem)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

mkApp :: Component Unit
mkApp = do
  todoForm <- mkTodoForm
  todoItem <- mkTodoItem
  component "App" \_ -> React.do
    todos /\ setTodos <- useState (Nothing :: Maybe (Array Todo))
    error /\ setError <- useState' (Nothing :: Maybe String)

    let
      -- Failures surface as a message instead of touching the todo list.
      runRequest :: forall a. Aff a -> (a -> Effect Unit) -> Effect Unit
      runRequest aff onSuccess = launchAff_ do
        result <- attempt aff
        liftEffect case result of
          Left e -> setError $ Just $ message e
          Right a -> setError Nothing *> onSuccess a

      addTodo title = runRequest (createTodo title) \created ->
        setTodos $ map (_ <> [ created ])

      toggleTodo todo = runRequest
        (updateCompleted todo.id (not todo.completed))
        \updated ->
          setTodos $ map (map \t -> if t.id == updated.id then updated else t)

      removeTodo todo = runRequest (deleteTodo todo.id) \_ ->
        setTodos $ map (filter \t -> t.id /= todo.id)

    useEffectOnce do
      runRequest fetchTodos \fetched -> setTodos \_ -> Just fetched
      pure mempty

    pure $ R.div_
      [ R.h1_ [ R.text "todo" ]
      , todoForm { onSubmit: addTodo }
      , case error of
          Nothing -> mempty
          Just msg -> R.p_ [ R.text msg ]
      , case todos of
          Nothing -> R.text "Loading..."
          Just loaded -> R.ul_ $ loaded <#> \todo ->
            keyed (show todo.id) $ todoItem
              { todo
              , onToggle: toggleTodo todo
              , onDelete: removeTodo todo
              }
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
