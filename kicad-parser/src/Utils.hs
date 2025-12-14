module Utils
    ( toGlbalPos, scaleCoord, toDble, getExtremeX, getExtremeY
    ) where

import Types

toGlbalPos :: TripleD -> PairD -> PairD
toGlbalPos (xf, yf, tf) (xp, yp) = (xf + xp', yf + yp')
  where
    tf' = tf * (pi / 180)
    xp' = xp * cos(tf') - yp * sin(tf')
    yp' = xp * sin(tf') + yp * cos(tf')

scalePoint :: Double -> Int -> Int
scalePoint c f = round (c * (fromIntegral f))

scaleCoord :: Int -> PairD -> PairI
scaleCoord f (x,y) = (scalePoint x f, scalePoint y f)

-- https://hackage.haskell.org/package/base-4.21.0.0/docs/Prelude.html#v:read
toDble :: String -> Double
toDble = read

getExtremeX :: (Int -> Int -> Int) -> Int -> [(Int, Int)] -> Int
getExtremeX _ defaultV []         = defaultV
getExtremeX f defaultV ((x,_):xs) = f x $ getExtremeX f defaultV xs

getExtremeY :: (Int -> Int -> Int) -> Int -> [(Int, Int)] -> Int
getExtremeY _ defaultV []         = defaultV
getExtremeY f defaultV ((_,y):xs) = f y $ getExtremeY f defaultV xs