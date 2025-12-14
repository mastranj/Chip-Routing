-- Consulted https://dl.acm.org/doi/pdf/10.1145/201310.201328 for ideas
-- about net ordering
-- Consulted https://www.eecg.toronto.edu/~vaughn/papers/iccad96.pdf for
-- bounding box idea in net ordering
--  - Along with https://en.wikipedia.org/wiki/Minimum_bounding_box

module NetTools.NetOrderer
    ( optimNetsOrder, optimNLOrder, getNetBound
    ) where

import CRTypes.Types
import CRUtils.Heuristics
import qualified Data.List as List
import qualified Data.Set as Set

optimNLOrder :: Bool -> NetList -> NetList
optimNLOrder b nl
  | b == False = nl
  | otherwise  = reverse $ List.sortBy (compareNetBound) nl

compareNetBound :: Net -> Net -> Ordering
compareNetBound n1 n2 = compare (getNetArea n1) (getNetArea n2)

getNetBound :: Net -> Bounds
getNetBound n = ((minX,minY),(maxX,maxY))
  where
    tmpMax = 1000000
    tmpMin = -10
    (maxX, maxY) = getNetExtremes max tmpMin n
    (minX, minY) = getNetExtremes min tmpMax n

getNetArea :: Net -> Int
getNetArea n = (maxX-minX+1)*(maxY-minY+1)
  where
    tmpMax = 1000000
    tmpMin = -10
    (maxX, maxY) = getNetExtremes max tmpMin n
    (minX, minY) = getNetExtremes min tmpMax n

getNetExtremes :: (Int -> Int -> Int) -> Int -> Net -> (Int, Int)
getNetExtremes _ exDef []                       = (exDef, exDef)
getNetExtremes f exDef (((x,y,_),(x2,y2,_)):ns) = (exX,   exY  )
  where
    (exX2, exY2) = getNetExtremes f exDef ns
    exX = f exX2 $ f x $ f exDef x2
    exY = f exY2 $ f y $ f exDef y2

optimNetsOrder :: Bool -> NetList -> NetList
optimNetsOrder b = map (orderNet b)

orderNet :: Bool -> Net -> Net
orderNet b nl
  | not b          = nl
  | length nl >= 2 = getNetOrdering (_getPoints nl)
  | otherwise      = nl

getNetOrdering :: [Coord] -> Net
getNetOrdering cs = (c1,c2) : _getNetOrdering (c1 : [c2]) womiddle2
  where
    c1 = _getMiddleCoord cs
    womiddle = filter (\x -> x /= c1) cs
    c2 = _getMiddleCoord womiddle
    womiddle2 = filter (\x -> x /= c2) womiddle

_getNetOrdering :: [Coord] -> [Coord] -> Net
_getNetOrdering _ []             = []
_getNetOrdering conned (c:cs) = (_attachPoint conned (-10000,-10000,-100) c) : 
                                  (_getNetOrdering (c : conned) cs)

_attachPoint :: [Coord] -> Coord -> Coord -> Connection
_attachPoint []      bestC c = (c, bestC)
_attachPoint (c2:cs) bestC c
  | dist > distbest          = _attachPoint cs bestC c
  | otherwise                = _attachPoint cs c2 c
  where
    dist                     = manhattan3DBounded (c, c2)
    distbest                 = manhattan3DBounded (c, bestC)

_getPoints :: Net -> [Coord]
_getPoints = Set.toList . Set.fromList . __getPoints
  where
    __getPoints :: Net -> [Coord]
    __getPoints []           = []
    __getPoints ((c1,c2):nl) = c1 : c2 : _getPoints nl

_orderCoords :: [Coord] -> [Coord]
_orderCoords = List.sortBy (\c c2 -> compareC c c2)

_getMiddleCoord :: [Coord] -> Coord
_getMiddleCoord cs = head $ drop midpt $ _orderCoords cs
  where midpt      = (length cs) `div` 2

compareC :: Coord -> Coord -> Ordering
compareC (x,y,l) (x2,y2,l2) = compare (x+y+l) (x2+y2+l2)