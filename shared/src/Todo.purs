module Shared.Todo (Todo, NewTodo, TodoPatch) where

type Todo = { id :: Int, title :: String, completed :: Boolean }
type NewTodo = { title :: String }
type TodoPatch = { completed :: Boolean }
