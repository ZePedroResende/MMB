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

data Tweet =
  Tweet { text :: !Text,
          id   :: Int
          } deriving (Show, Generic)

instance FromJSON Tweet
instance ToJSON Tweet

consumerKey = ""
consumerSecret = ""
accessToken = ""
accessSecret = ""


oauth :: OAuth
oauth =
  newOAuth { oauthServerName     = "api.twitter.com"
           , oauthConsumerKey    = consumerKey
           , oauthConsumerSecret = consumerSecret
             }

cred :: Credential
cred = newCredential accessToken
                       accessSecret


tweet :: String -> IO (Either String Tweet) 
tweet text =  do
  requestUrl <- parseUrl $ "https://api.twitter.com/1.1/statuses/update.json"
  let request = urlEncodedBody [("status", pack text)] requestUrl
  manager <- newManager tlsManagerSettings 
  signedrequest <- signOAuth oauth cred request
  res <- httpLbs signedrequest manager
  return $ eitherDecode $ responseBody res





main:: IO (Either String Tweet)
main = do
  temp <- fmap show getCurrentTime -- current clock time 
  frase <- getLine
  tweet $ temp ++ " " ++ frase
  -- tweet frase
