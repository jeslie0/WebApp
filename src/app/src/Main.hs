{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Network.HTTP.Types
import           Network.Wai
import           Network.Wai.Handler.Warp

main :: IO ()
main = run 3001 app

app :: Application
app request respond =
  case (parseMethod (requestMethod request), pathInfo request) of
  (Right GET, _) -> respond $
    responseLBS ok200 [] $
    mconcat [ "<html><body>"
            , "<h1>Hello Haskell!</h1>"
            , "</body></html>"]

  _ ->
    respond $ responseLBS notFound404 [] "<h1>Not Found</h1"

