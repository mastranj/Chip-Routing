module NetTools.Partitioners.OverlapPartitioner
    (partsByNonOverlap
    ) where

import CRTypes.Types
import CRUtils.Utils
import NetTools.NetOrderer

partsByNonOverlap :: Int -> NetList -> Problems
partsByNonOverlap o = filter (not . isEmpty) . _getNonoverlapGrp [] o

_getNonoverlapGrp :: Problems -> Int -> NetList -> Problems
_getNonoverlapGrp currps _ [] = currps
_getNonoverlapGrp currps o nl
  | length nonoverlaps == 0   = othrs : currps
  | otherwise                 = _getNonoverlapGrp (nonoverlaps : currps) o othrs
  where
    (nonoverlaps, othrs) = getNonoverlapNL o [] nl 

getNonoverlapNL :: Int -> NetList -> NetList -> (NetList, NetList)
getNonoverlapNL _ blder []       = (blder, [])
getNonoverlapNL ov blder others
  | length nlWithoutOverlap == 0 = (blder, others)
  | otherwise                    = 
    getNonoverlapNL ov (firstNonoverlap : blder) newOthersWithoutFirstNO
  where
    nlWithoutOverlap        = filter (\o -> not (doesNetOverlap ov o blder)) others
    firstNonoverlap         = head nlWithoutOverlap
    newOthersWithoutFirstNO = filter (\o -> o /= firstNonoverlap) others

doesNetOverlap :: Int -> Net -> NetList -> Bool
doesNetOverlap o n = any (\x -> x == True) . map (\ln -> doNetsOverlap o ln n)

doNetsOverlap :: Int -> Net -> Net -> Bool
doNetsOverlap o nl nl2 = doOverlap o (getNetBound nl) $ getNetBound nl2

doOverlap :: Int -> Bounds -> Bounds -> Bool
doOverlap o b1 b2 = isOverlap b1 b2 || isOverlap b2 b1
  where
    isOverlap ((minX,minY),(maxX,maxY)) ((minX2,minY2),(maxX2,maxY2)) =
      minX2 <= maxX + o && minY2 <= maxY + o && minX2 + o >= minX && minY2 + o >= minY ||
      maxX2 <= maxX + o && maxY2 <= maxY + o && maxX2 + o >= minX && maxY2 + o >= minY
