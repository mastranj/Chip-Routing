module FileCleaner
    ( cleanFile
    ) where

import Types
import qualified Data.Map as Map
import qualified Data.Set as Set
import Data.List.Split (splitOn)
import Data.List (sortOn, groupBy)

type NetMap = Map.Map (Int, Int) NetRep

cleanFile :: String -> String -> IO ([(Int, Int)], [[NetRep]])
cleanFile inp outp = do
  writeFile   outp ""
  writeFile  (outp ++ ".onelayer.txt") ""
  contents            <- readFile inp
  let netMap          = _genNetMap Map.empty $ lines contents
  let unsortedNetlist = map (snd) $ Map.toList netMap
  let sortedNetList   = sortOn fstNetRep unsortedNetlist
  let groupedNetList  = groupBy netRepSort sortedNetList
  _writeCleanFile outp sortedNetList

  let coords = Set.toList $ Set.fromList $ map (fst) $ Map.toList netMap
  return (coords, groupedNetList)
  where
    fstNetRep :: NetRep -> String
    fstNetRep (nid,_,_,_,_)                 = nid
    netRepSort :: NetRep -> NetRep -> Bool
    netRepSort (nid,_,_,_,_) (nid2,_,_,_,_) = nid == nid2

_genNetMap :: NetMap -> [String] -> NetMap
_genNetMap m []     = m
_genNetMap m (l:ls) = _genNetMap m' ls
  where 
    netRep@(_, x, y, _, _) = _toNetInfo l
    m'                     = Map.insert (x,y) netRep m
  
_toNetInfo :: String -> NetRep
_toNetInfo s = case splitOn " " s of
  (nid:x:y:name:layer:_) -> (nid, read x, read y, name, layer)
  _                  -> ("-1", 0, 0, "", "") 

_writeCleanFile :: String -> [NetRep] -> IO ()
_writeCleanFile   f []                        = do
  putStrLn $ "Generated " ++ f ++ " and " ++ f ++ ".onelayer.txt"
_writeCleanFile   f ((nid,x,y,name,layer):ls) = do
  let f2 = f ++ ".onelayer.txt"
  appendFile      f  $ unwords [nid,show x,show y,name,layer]
  appendFile      f  "\n"
  appendFile      f2 $ unwords [nid,show x,show y,name,"TOP"]
  appendFile      f2 "\n"
  _writeCleanFile f ls

