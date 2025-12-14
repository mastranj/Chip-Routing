module CRUtils.Args
    ( showArgs
    ) where

import CRTypes.Types (Args)

showArgs :: Args -> String -> String -> String -> String -> String -> String
         -> IO ()
showArgs (cf, pf, pfInc, pfMax, hf) maxT maxB optN optNL parT isB = do
  putStrLn $ "\n  =================================================\n"
  putStrLn $ "\t connFile = " ++      cf
  putStrLn $ "\t pf       = " ++ show pf
  putStrLn $ "\t pfInc    = " ++ show pfInc
  putStrLn $ "\t pfMax    = " ++ show pfMax
  putStrLn $ "\t hf       = " ++ show hf
  putStrLn $ "\t maxT     = " ++      maxT
  putStrLn $ "\t maxB     = " ++      maxB
  putStrLn $ "\t optimNL  = " ++      optNL
  putStrLn $ "\t optimN   = " ++      optN
  putStrLn $ "\t parType  = " ++      parT
  putStrLn $ "\t isBatch  = " ++      isB
  putStrLn $ "\n  =================================================\n\n"