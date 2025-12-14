module NetTools.InputProcessor
    ( toSegmentsIgnL
    ) where

import CRTypes.Types
import Data.List (partition)
import Data.List.Split (splitOn)
import qualified Data.Set as Set

toSegmentsIgnL :: String -> [String] -> Int -> Int -> NetList
toSegmentsIgnL ignoreL ls maxT maxB = cleanNets
  where 
    cleanNets = _postClean $ _toSegments allNets ls ignoreL maxT maxB
    allNets   = Set.toList $ _getNetIds ignoreL ls

_postClean :: NetList -> NetList
_postClean = filter (\x -> length x >= 1)

_toSegments :: [String] -> [String] -> String -> Int -> Int -> NetList
_toSegments [] _ _ _ _              = []
_toSegments (n:ns) ls igL maxT maxB = 
  _processNet ls n igL maxT maxB : _toSegments ns ls igL maxT maxB

_getNetIds :: String -> [String] -> Set.Set String
_getNetIds _ [] = Set.empty
_getNetIds ignoreL (l:ls)
  | la /= ignoreL = Set.insert netId (_getNetIds ignoreL ls)
  | otherwise     = _getNetIds ignoreL ls
    where 
      (netId, la) = case splitOn " " l of
        (n:_:_:_:lay:_) -> (n, lay)
        li              -> error $ "Invalid inp file. Cannot parse: " ++ show li

_processNet :: [String] -> String -> String -> Int -> Int -> Net
_processNet ls nid ignoreL maxT maxB = take maxT top ++ take maxB bottom
  where
    (bottom, top) = partition (\((_,_,l),(_,_,l2)) -> l == 0 || l2 == 0) net 
    net = _coordsToPairs $ _getNetCoords ls nid ignoreL

_getNetCoords :: [String] -> String -> String -> [Coord] 
_getNetCoords [] _ _ = []
_getNetCoords (l:ls) netId ignoreL
  | ignoreL == la   = prevL
  | n == netId      = (x,y,lI) : prevL
  | otherwise       = prevL
  where
    (n,x,y,_,la)    = _grab5 $ splitOn " " l
    lI
      | la == "TOP" = 1
      | otherwise   = 0
    prevL           = _getNetCoords ls netId ignoreL

_coordsToPairs :: [Coord] -> Net
_coordsToPairs coords
  | length coords == 1 = []
  | otherwise          = process tal hed
  where
    tal                    = tail coords
    hed                    = head coords
    process :: [Coord] -> Coord -> Net
    process [] _           = []
    process (curr:cs) prev = (prev, curr): process cs curr

_grab5 :: [String] -> (String, Int, Int, String, String)
_grab5 [a,b,c,d,e] = (a,read b,read c,d,e)
_grab5 l           = error $ "Invalid input file. Cannot parse line: " ++ show l