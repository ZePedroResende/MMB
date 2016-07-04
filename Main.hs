{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module Main where 
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
import DM

data Users = 
    Users{screen_name :: String} deriving(Show, Generic)


data Tweet =
  Tweet { text :: !Text,
         retweeted :: Bool,
         user :: Users
          } deriving (Show, Generic)

instance FromJSON Users
instance ToJSON Users
instance FromJSON Tweet
instance ToJSON Tweet



tweet :: String -> IO (Either String Tweet) 
tweet text =  do
  requestUrl <- parseUrl $ "https://api.twitter.com/1.1/statuses/update.json"
  let request = urlEncodedBody [("status", pack text)] requestUrl
  manager <- newManager tlsManagerSettings 
  signedrequest <- signOAuth oauth cred request
  res <- httpLbs signedrequest manager
  return $ eitherDecode $ responseBody res


timeline :: String  -> IO (Either String [Tweet]) 
timeline name = do
      request <- parseUrl $ "https://api.twitter.com/1.1/usertimeline.json?screen_name=" ++ name
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
