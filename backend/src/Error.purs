module Backend.Error (ApiError(..), Handler) where

import Control.Monad.Except (ExceptT)
import Effect.Aff (Aff)

data ApiError = BadRequest String | NotFound | ServerError String

type Handler = ExceptT ApiError Aff
