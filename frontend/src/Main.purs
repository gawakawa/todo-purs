module Main where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (attempt)
import Effect.Exception (message, throw)
import Fetch (fetch)
import React.Basic.DOM as R
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Hooks (Component, component)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

mkApp :: Component Unit
mkApp = component "App" \_ ->
  React.do
    result <- useAff unit $ attempt do
      { status, text } <- fetch "/api/hello/world" {}
      body <- text
      pure { status, body }
    let
      content = case result of
        Nothing -> R.text "Loading..."
        Just (Left err) -> R.text $ message err
        Just (Right { status, body })
          | status == 200 -> R.text body
          | otherwise -> R.text $ "unexpected status: " <> show status
    pure $ R.div_
      [ R.h1_ [ R.text "todo" ]
      , content
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
