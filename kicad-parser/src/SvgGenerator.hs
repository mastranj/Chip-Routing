module SvgGenerator
    ( generateSvg
    ) where 

import Types
import Data.List (isPrefixOf)

generateSvg :: String -> (Int,Int,Int,Int,Int) -> [[NetRep]] -> IO ()
generateSvg outp (pad,minX,maxX',minY,maxY') net = do
  writeFile outp $ "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 " 
    ++ show maxX' ++ " " ++ show maxY' ++ "\" width=\"400\" height=\"400\">\n"
  _parseNetRepLL (pad,minX,minY) outp net
  appendFile outp "</svg>"
  putStrLn $ "Generated " ++ outp

_parseNetRepLL :: (Int,Int,Int) -> String -> [[NetRep]] -> IO ()
_parseNetRepLL _ _ [] = return ()
_parseNetRepLL   ip f (netlist:others) = do
  _parseNetRepL  ip f (head netlist) (tail netlist)
  _parseNetRepLL ip f others

_parseNetRepL :: (Int,Int,Int) -> String -> NetRep -> [NetRep] -> IO ()
_parseNetRepL _ _ _ [] = return ()
_parseNetRepL ip f (_,x,y,_,layer) (to@(_,toX,toY,_,_):ls) = do
  writeLinesToSvg ip f x y toX toY layer
  _parseNetRepL ip f to ls
  
writeLinesToSvg :: (Int,Int,Int) -> String -> Int -> Int -> Int -> Int
                -> String -> IO ()
writeLinesToSvg (pad,minX,minY) outp x y toX toY layer = do
  let padding = pad `div` 2
  appendFile outp $ "\t<polyline points=\"" 
    ++ show (x-minX+padding) ++ " " ++ show (y-minY+padding) ++ " " 
    ++ show (toX-minX+padding) ++ " " ++ show (toY-minY+padding)
    ++ "\" fill=\"none\" stroke=\"" 
    ++ getLayerColor layer ++ "\" stroke-width=\"3\" />\n"

getLayerColor :: String -> String
getLayerColor l
  | l == "TOP"          = "green"
  | "*" `isPrefixOf` l  = "magenta"
  | otherwise           = "blue"
