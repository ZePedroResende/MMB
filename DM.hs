{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module DM where 

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

data DM = 
    DM { text :: !Text,
         sender_screen_name :: String
        } deriving (Show, Generic)


instance FromJSON DM
instance ToJSON DM

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




dm :: String -> String -> IO(Either String DM)
dm texto name = do
  requestUrl <- parseUrl $ "https://api.twitter.com/1.1/direct_messages/new.json?text=" ++ texto ++ "&screen_name=" ++ name
  let request = urlEncodedBody [] requestUrl
  manager <- newManager tlsManagerSettings
  signedrequest <- signOAuth oauth cred request
  res <- httpLbs signedrequest manager
  return $ eitherDecode $ responseBody res 


inbox :: IO(Either String [DM])
inbox = do
  request <- parseUrl $ "https://api.twitter.com/1.1/direct_messages.json"
  manager <- newManager tlsManagerSettings
  signedrequest <- signOAuth oauth cred request
  res <- httpLbs signedrequest manager
  return $ eitherDecode $ responseBody res 
