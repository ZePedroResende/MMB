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



tweet :: String -> IO (Either String Tweet) -- caso o  requeste nao tenha erros e seja aceite devolve a parte direita da string , se nao da o erro na parte esquerda da string 
tweet text =  do
  requestUrl <- parseUrl $ "https://api.twitter.com/1.1/statuses/update.json" -- o url de requeste da API do twitter 
  let request = urlEncodedBody [("status", pack text)] requestUrl -- pack text transforma a msg numa byteString (unicode) 
  -- e altera o url de forma a ter a msg , isto podia ser facilmente substituido por um ++ na string de cima 
  -- A funçao urlEncodedBody transforma o requeste no metodo POST em vez do GET , isto esta definido na API qual o
  -- metodo que de ser utilizado
  manager <- newManager tlsManagerSettings -- http manager , a sua utilizaçao e descrito na documentaçao na net
  signedrequest <- signOAuth oauth cred request -- com as credenciais dadas na api vai auntenticar o request acima definido 
  res <- httpLbs signedrequest manager -- com o manager vai vai fazer o pedido 
  return $ eitherDecode $ responseBody res -- se a resposta for bem sucedido vai ter um tweet com a msg , se é ou nao é retweet
  -- se tiver um erro vai receber os erros dados na api . E facil conferir isto utilizando um  nick falso 

-- Esta decomentaçao pode ser facilmente aplicada ao resto do codigo , sendo que quando nao temos a funçao
-- urlEncodedBody pode ser considerada um requeste com o metodo GET 
-- Existe tambem outro tipo de data "DM " utilizado para DM e pode ser encontrado no modulo DM.hs 


timeline :: String  -> IO (Either String [Tweet]) 
timeline name = do
      request <- parseUrl $ "https://api.twitter.com/1.1/usertimeline.json?screen_name=" ++ name
      manager <- newManager tlsManagerSettings
      signedrequest <- signOAuth oauth cred request
      res <- httpLbs signedrequest manager
      return $ eitherDecode $ responseBody res 



main:: IO ()
main = do
  putStrLn " 1)Tweet\n 2)Timeline\n 3)DM\n 4)Inbox\n"
  numero <- readLn
  case numero of
      1 -> do
          putStrLn "frase\n"
          frase <- getLine
          tweet frase 
          return ()
      2 -> do 
          putStrLn "nome\n"
          nome <- getLine
          timeline nome
          return ()
      3 -> do
          putStrLn "frase\n"
          frase <- getLine
          putStrLn "nome\n"
          nome <- getLine
          dm frase nome
          return ()
      4 -> do
          inbox
          return ()
      otherwise -> do
          putStrLn "Invalido"
 

{-main:: IO (Either String Tweet)
main = do
  temp <- fmap show getCurrentTime -- current clock time 
  frase <- getLine
  tweet $ temp ++ " " ++ frase
  -- tweet frase
-}
