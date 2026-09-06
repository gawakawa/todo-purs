module TodoForm (Props, mkTodoForm) where

import Prelude

import Data.Maybe (fromMaybe)
import Data.String (trim)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import React.Basic.DOM as R
import React.Basic.DOM.Events (preventDefault, targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, useState')
import React.Basic.Hooks as React

type Props = { onSubmit :: String -> Effect Unit }

mkTodoForm :: Component Props
mkTodoForm = component "TodoForm" \{ onSubmit } -> React.do
  draft /\ setDraft <- useState' ""

  let
    submit = handler preventDefault \_ ->
      case trim draft of
        "" -> pure unit
        title -> do
          onSubmit title
          setDraft ""

  pure $ R.form
    { onSubmit: submit
    , children:
        [ R.input
            { value: draft
            , onChange: handler targetValue (setDraft <<< fromMaybe "")
            }
        , R.button { type: "submit", children: [ R.text "追加" ] }
        ]
    }
