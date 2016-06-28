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
           , oauthConsumerKey    = "mOIMIVotbUWF2TGQQDSMAiXKT"
           , oauthConsumerSecret = "cAGlK1OHtpgU8ErhofikPldJ610ro6kc4PHcs5yJDdEsLCYkKz"
             }

mycred :: Credential
mycred = newCredential "445589918-gvtVkhK3W3akbUVrmtetRrEhzicGoLQvH4eBf6DV"
                       "aACU47RCaC1iHyoi93p8FngctZW0EsiHUX9zOp3Gbx57g"

-- ||| Functions that interact with the Twitter API

-- | This function reads a timeline JSON and parse it using the 'Tweet' type.
timeline :: String -- ^ Screen name of the user
         -> IO (Either String [Tweet]) -- ^ If there is any error parsing the JSON data, it
                                       --   will return 'Left String', where the 'String'
                                       --   contains the error information.
timeline name = do
  -- Firstly, we create a HTTP request with method GET.
  req <- parseUrl $ "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=" ++ name
  -- Using a HTTP manager, we authenticate the request and send it to get a response.
  res <- withManager $ \m -> do
           -- OAuth Authentication. 'signOAuth' modifies the HTTP header adding the
           -- appropriate authentication.
           signedreq <- signOAuth myoauth mycred req
           -- Send request.
           httpLbs signedreq m
  -- Decode the response body.
  return $ eitherDecode $ responseBody res

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
  temp <- fmap show getCurrentTime
  --tempo <-currentTime
  tweet temp
   {-
-- | The main function. This just sets up a Timer.
main :: IO (Timer IO)
main = do
  -- Starts a timer that runs realMain every 10 minutes
  repeatedTimer runMain (mDelay 1)
  -}
