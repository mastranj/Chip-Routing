module CRUtils.Heuristics
    ( H,
      manhattan3DBounded, manhattan3D
    ) where

import CRTypes.Types
import CRUtils.HelperFuncs (layers)

type H = Connection -> Double

manhattan3DBounded :: H
manhattan3DBounded cs@((x,y,l), (x2,y2,l2))
  | x < 0 || y < 0 || x2 < 0 || y2 < 0 ||
    l < 0 || l > layers || l2 < 0 || l2 > layers = 100000
  | otherwise                                    = 1.45*manhattan3D cs

manhattan3D :: H
manhattan3D ((x,y,l), (x2,y2,l2)) =
  sqrt $ fromIntegral $ (_square (x-x2)) + (_square (y-y2)) + (_square (l-l2)) 

_square :: Int -> Int
_square x = x * x