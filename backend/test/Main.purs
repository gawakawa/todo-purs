module Test.Main where

import Prelude

import Data.Argonaut (encodeJson)
import Data.Either (Either(..), isLeft)
import Effect (Effect)
import Effect.Exception (Error, message)
import Test.Unit (Test, suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)
import Todo (decodeTodo, validateTitle)

-- Error has no Eq instance, so unwrap Right before comparing.
assertRight :: forall a. Eq a => Show a => a -> Either Error a -> Test
assertRight expected = case _ of
  Left err -> Assert.assert ("expected Right, got Left: " <> message err) false
  Right actual -> Assert.equal expected actual

main :: Effect Unit
main = runTest do
  suite "validateTitle" do
    test "keeps a valid title" do
      assertRight "todo" $ validateTitle "todo"
    test "trims surrounding whitespace" do
      assertRight "todo" $ validateTitle "  todo  "
    test "rejects an empty title" do
      Assert.assert "expected Left" $ isLeft $ validateTitle ""
    test "rejects a whitespace-only title" do
      Assert.assert "expected Left" $ isLeft $ validateTitle "   "

  suite "decodeTodo" do
    test "decodes completed = 1 as true" do
      assertRight { id: 1, title: "a", completed: true }
        $ decodeTodo
        $ encodeJson { id: 1, title: "a", completed: 1 }
    test "decodes completed = 0 as false" do
      assertRight { id: 1, title: "a", completed: false }
        $ decodeTodo
        $ encodeJson { id: 1, title: "a", completed: 0 }
    test "rejects a boolean completed field" do
      Assert.assert "expected Left" $ isLeft $ decodeTodo $ encodeJson
        { id: 1, title: "a", completed: true }
    test "rejects a row missing a field" do
      Assert.assert "expected Left" $ isLeft $ decodeTodo $ encodeJson
        { id: 1, title: "a" }
