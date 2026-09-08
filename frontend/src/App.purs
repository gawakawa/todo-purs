module Frontend.App (mkApp) where

import Prelude

import Data.Array (filter)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff (attempt, launchAff_)
import Effect.Class (liftEffect)
import Effect.Exception (message)
import Frontend.Api (createTodo, deleteTodo, fetchTodos, updateCompleted)
import Frontend.TodoForm (mkTodoForm)
import Frontend.TodoItem (mkTodoItem)
import React.Basic (keyed)
import React.Basic.DOM as R
import React.Basic.Hooks (Component, component, useEffectOnce, useState, useState')
import React.Basic.Hooks as React
import Shared.Todo (Todo)

mkApp :: Component Unit
mkApp = do
  todoForm <- mkTodoForm
  todoItem <- mkTodoItem
  component "App" \_ -> React.do
    todos /\ setTodos <- useState (Nothing :: Maybe (Array Todo))
    error /\ setError <- useState' (Nothing :: Maybe String)

    let
      handleSubmit title = launchAff_ do
        result <- attempt $ createTodo title
        liftEffect case result of
          Left e -> setError $ Just $ message e
          Right created -> do
            setError Nothing
            setTodos $ map (_ <> [ created ])

      handleToggle todo = launchAff_ do
        result <- attempt $ updateCompleted todo.id (not todo.completed)
        liftEffect case result of
          Left e -> setError $ Just $ message e
          Right updated -> do
            setError Nothing
            setTodos $ map (map \t -> if t.id == updated.id then updated else t)

      handleDelete todo = launchAff_ do
        result <- attempt $ deleteTodo todo.id
        liftEffect case result of
          Left e -> setError $ Just $ message e
          Right _ -> do
            setError Nothing
            setTodos $ map (filter \t -> t.id /= todo.id)

    useEffectOnce do
      launchAff_ do
        result <- attempt fetchTodos
        liftEffect case result of
          Left e -> setError $ Just $ message e
          Right fetched -> setTodos \_ -> Just fetched
      pure mempty

    pure $ R.div_
      [ R.h1_ [ R.text "todo" ]
      , todoForm { onSubmit: handleSubmit }
      , case error of
          Nothing -> mempty
          Just msg -> R.p_ [ R.text msg ]
      , case todos of
          Nothing -> R.text "Loading..."
          Just loaded -> R.ul_ $ loaded <#> \todo ->
            keyed (show todo.id) $ todoItem
              { todo
              , onToggle: handleToggle todo
              , onDelete: handleDelete todo
              }
      ]
