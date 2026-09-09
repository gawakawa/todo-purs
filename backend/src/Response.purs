module Backend.Response (respond) where

import Prelude

import Backend.Error (ApiError(..), Handler)
import Control.Monad.Except (runExceptT)
import Data.Either (either)
import Effect.Aff.Class (class MonadAff, liftAff)
import HTTPurple (Response, badRequest, internalServerError, notFound)

respond
  :: forall m a. MonadAff m => (a -> m Response) -> Handler a -> m Response
respond onOk handler = liftAff (runExceptT handler) >>= either errorResponse
  onOk

errorResponse :: forall m. MonadAff m => ApiError -> m Response
errorResponse = case _ of
  BadRequest msg -> badRequest msg
  NotFound -> notFound
  ServerError msg -> internalServerError msg
