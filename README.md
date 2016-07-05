# MMB
Small twitter client for cli written in haskell


#Cabal dependencies 
-----------------------------------------------------------------------
>http-conduit

>authenticate-oauth 

>old-time

>timers 

>Control.Concurrent.Suspend.Lifted

#How to setup
-------------------------------------------------------------------------
 You need:
  1 - twitter account bounded to a cell phone number 
  
  2 - API keys that you get at dev.twitter.com
  
  3 - Put the keys in the file DM.hs in each corresponding camp 
  
  4 - ghci installed (if you are in windows you probable need a c compiler) 
  
  5 - cabal update 
  
  6 - cabal install http-conduit authenticate-oauth old-time timers Control.Concurrent.Suspend.Lifted
  
  7 - ghci Main.hs for calling function  or ghc Main.hs for scripting 

#How to use 
----------------------------------------------------------------------------
Theres different ways to use this client :
 
  The first is inside ghci where you invoke one of the available functions
      
      tweet "your tweet"
        ex: tweet "im using MMB"
         
      timeline "user"
        ex: username = @MMB  , then you do , timeline "MMB"
        
      dm "your dm" "username"
        ex: dm "im using MMB" "MMB"
        
      inbox  
        ex: you use this to see the last 20 dms received
        
  
  The second is transforming the main. 
  You can use this to script the program tranforming it in to a bot !
  
  
  

#Notes
This program at first was a bot , but then for my needs it evolved to a small client 
This is very very simple and was mostly written for a better understanding of IO in haskell , http in haskell and the twitter api

