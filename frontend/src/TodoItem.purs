module TodoItem (Props, mkTodoItem) where

import Prelude

import Effect (Effect)
import React.Basic.DOM as R
import React.Basic.Events (handler_)
import React.Basic.Hooks (Component, component)
import Shared.Todo (Todo)

type Props =
  { todo :: Todo
  , onToggle :: Effect Unit
  , onDelete :: Effect Unit
  }

mkTodoItem :: Component Props
mkTodoItem = component "TodoItem" \{ todo, onToggle, onDelete } ->
  pure $ R.li_
    [ R.input
        { type: "checkbox"
        , checked: todo.completed
        , onChange: handler_ onToggle
        }
    , R.text todo.title
    , R.button
        { onClick: handler_ onDelete
        , children: [ R.text "削除" ]
        }
    ]
