module Shared.Todo
  ( CreateTodoRequest
  , CreateTodoResponse
  , DeleteTodoRequest
  , DeleteTodoResponse
  , ListTodosRequest
  , ListTodosResponse
  , SetCompletedBody
  , SetCompletedRequest
  , SetCompletedResponse
  , Todo
  ) where

import Prelude

type Todo = { id :: Int, title :: String, completed :: Boolean }

type ListTodosRequest = {}
type ListTodosResponse = Array Todo

type CreateTodoRequest = { title :: String }
type CreateTodoResponse = Todo

type SetCompletedRequest = { id :: Int, completed :: Boolean }
type SetCompletedResponse = Todo
type SetCompletedBody = { completed :: Boolean }

type DeleteTodoRequest = { id :: Int }
type DeleteTodoResponse = Unit
