-- This code was originally writen by  Pranav Vishnu Ramabhadran
-- visite him and the code at  : https://github.com/pvrnav/haskell-twitter-bot
{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

import Data.ByteString (ByteString)
import Data.ByteString.Char8 (pack)
import Network.HTTP.Conduit
import Web.Authenticate.OAuth
import Data.Aeson
import Data.Time.Clock (UTCTime)
import Data.Time.Clock
import Data.Text (Text)
import GHC.Generics
import System.Time
import Control.Concurrent.Timer.Lifted
import Control.Concurrent.Suspend.Lifted
import Control.Monad
import qualified Data.Text    as Text
import qualified Data.Text.IO as Text


-- ||| Private Keys and Credentials
data Tweet =
  Tweet { text :: !Text,
          id   :: Int
          } deriving (Show, Generic)

instance FromJSON Tweet
instance ToJSON Tweet


myoauth :: OAuth
myoauth =
  newOAuth { oauthServerName     = "api.twitter.com"
           , oauthConsumerKey    = consumerKey
           , oauthConsumerSecret = consumerSecret
             }

mycred :: Credential
mycred = newCredential accessToken
                       accessSecret


-- | This function takes a string to tweet out and sends a POST reqeuest to do so.
tweet :: String -- ^ String to tweet out
         -> IO (Either String Tweet) -- ^ If there is any error parsing the JSON data, it
                                       --   will return 'Left String', where the 'String'
                                       --   contains the error information.
tweet text = do
  -- Firstly, we create a HTTP request with method POST
  req1 <- parseUrl $ "https://api.twitter.com/1.1/statuses/update.json"
  let req = urlEncodedBody [("status", pack text)] req1 -- We need to use ByteStrings here
  -- Using a HTTP manager, we authenticate the request and send it to get a response.
  res <- withManager $ \m -> do
           -- OAuth Authentication. 'signOAuth' modifies the HTTP header adding the
           -- appropriate authentication.
           signedreq <- signOAuth myoauth mycred req
           -- Send request.
           httpLbs signedreq m
  -- Decode the response body.
  return $ eitherDecode $ responseBody res





-- | The actual work done by the main function.
main:: IO (Either String Tweet)
main = do
  temp <- fmap show getCurrentTime -- current clock time 
  frase <- getLine
  tweet $ temp ++ " " ++ frase
  -- tweet frase
