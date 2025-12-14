module NetTools.Partitioners.SlicePartitioner
    (partsByBounds, toGroupsSizeN
    ) where

import CRTypes.Types
import CRUtils.Utils
import Data.List (partition)

type PosStep = (Int, Int)

partsByBounds :: Int -> PosStep -> PosStep -> NetList -> Bounds -> Problems
partsByBounds o x y n b = 
  filter (not . isEmpty) (_partitionIntoGs o x y n b)

_partitionIntoGs :: Int -> PosStep -> PosStep -> NetList -> Bounds -> Problems
_partitionIntoGs o (cX, sX) = _partitionWorker o ((cX-sX), sX)

_partitionWorker :: Int -> PosStep -> PosStep -> NetList -> Bounds 
                         -> Problems
_partitionWorker o (cX, sX) (cY, sY) nl b = case _getNxtBnds o cX cY b sX sY of
    Nothing                  -> [nl]
    Just nb@((newX, newY),_) -> 
      inGroup : _partitionWorker o (newX, sX) (newY, sY) outGroup b
      where
        (inGroup, outGroup) = partitionNetsInBounds nb nl

toGroupsSizeN :: Int -> NetList -> Problems
toGroupsSizeN n nl
  | length nl > n = (take n nl) : toGroupsSizeN n (drop n nl)
  | otherwise     = [nl]

_getNxtBnds :: Int ->  Int -> Int -> Bounds -> Int -> Int -> Maybe Bounds
_getNxtBnds o cX cY b@((iX,_),(eX,eY)) sX sY
  | cY + sY   > eY = Nothing
  | cX + 2*sX > eX = _getNxtBnds o (iX-sX) (cY+sY) b sX sY
  | otherwise      = Just ((cX+(sX - o), cY), (cX+2*sX, cY+sY))

-- Returns ([nets in bounds], [nets out of bounds])
partitionNetsInBounds :: Bounds -> NetList -> (NetList, NetList)
partitionNetsInBounds b nl = partition (\n -> isNetInBounds b n) nl 

isNetInBounds :: Bounds -> Net -> Bool
isNetInBounds b = isEmpty . filter (\c -> not (isConnInBounds c b))

isConnInBounds :: Connection -> Bounds -> Bool
isConnInBounds ((x',y',_),(x'',y'',_)) ((x,y), (x2,y2)) =
  isCoordInBounds x' minX maxX && isCoordInBounds x'' minX maxX && 
  isCoordInBounds y' minY maxY && isCoordInBounds y'' minY maxY
  where
    (minX, maxX, minY, maxY) = (min x x2, max x x2, min y y2, max y y2)
    isCoordInBounds :: Int -> Int -> Int -> Bool
    isCoordInBounds pt mi ma = pt >= mi && pt <= ma