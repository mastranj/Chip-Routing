-- Citations:
-- 1. Used https://en.wikipedia.org/wiki/A*_search_algorithm for base of A*

module Negotiation.AStarConnAlg
    ( aStarConn, aStarConnH
    ) where

import CRTypes.Types
import CRUtils.Heuristics
import CRUtils.HelperFuncs
-- https://hackage-content.haskell.org/package/psqueues-0.2.8.2/docs/Data-IntPSQ.html
import Data.IntPSQ as Q 
import qualified Data.Map as Map

type Q = Q.IntPSQ Cost Cost

aStarConnH :: H -> CostM -> CostM -> Args -> Connection -> Segment
aStarConnH h overuseCost historyCost args n@(s, t) = reconPath n endPrevM
 where
  endPrevM = _aStarConn h t q Map.empty overuseCost historyCost scoreM args
  q        = Q.fromList [(coordToInt s, 0, 0)]
  scoreM   = fromListCostM [(s,0)]

aStarConn :: CostM -> CostM -> Args -> Connection -> Segment
aStarConn  = aStarConnH manhattan3DBounded

_aStarConn :: H -> Coord -> Q -> PrevM -> CostM -> CostM -> CostM 
           -> Args -> PrevM
_aStarConn h t q prevM oc hcm scoreM args = case Q.findMin q of
  Nothing        -> error "_aStarConn reached unreachable case."
  Just (curr,_,_)
    | curr == coordToInt t -> prevM
    | otherwise            -> _aStarConn h t q' pm' oc hcm scrm' args
      where
        (scrm',pm',q') = asStep args q (intToCoord curr) h t oc scoreM hcm prevM

asStep  :: Args -> Q -> Coord -> H -> Coord -> CostM -> CostM 
        -> CostM -> PrevM -> (CostM, PrevM, Q)
asStep args q curr = _asStep args (Q.deleteMin q) curr (getAllNeighbors curr)

_asStep  :: Args -> Q -> Coord -> Neighbors -> H -> Coord -> CostM 
         -> CostM -> CostM -> PrevM -> (CostM, PrevM, Q)
_asStep _ q _ [] _ _ _ scoreM _ prevM = (scoreM, prevM, q)
_asStep args q curr (neigh:ns) h targ overuseM scoreM hcm prevM =
  _asStep args q' curr ns h targ overuseM scoreM' hcm prevM'
  where
    (scoreM', prevM', q') =
      _asStepOnce h curr targ neigh scoreM overuseM hcm prevM q args
  
_asStepOnce :: H -> Coord -> Coord -> Coord -> CostM -> CostM -> CostM
            -> PrevM -> Q -> Args -> (CostM, PrevM, Q)
_asStepOnce h curr targ neigh scoreM oc hcm prevM q (_,pf,_,_,hf)
  | tentativeScore < scoreOfNeigh = ( scoreM', prevM', q' )
  | otherwise                     = ( scoreM,  prevM,  q  )
  where
    dcost = 100000

    scoreOfNeigh   = getCostD dcost scoreM neigh
    boardCostNeigh = 1 + (hf*getCost hcm neigh)
    overuseFac     = pf * getCostD 0.0 oc neigh
    neighborCost   = boardCostNeigh*(overuseFac+1)
    costToCurr     = getCostD dcost scoreM curr

    tentativeScore = costToCurr + neighborCost

    fscore         = tentativeScore + (h (neigh, targ))
    scoreM'        = insertCostM neigh tentativeScore scoreM
    prevM'         = Map.insert neigh curr prevM
    q'             = Q.insert (coordToInt neigh) fscore fscore q

-- Reconstruct the path
reconPath :: Connection -> PrevM -> Segment
reconPath n@(_,t) prevM = reverse $ t : (_reconPath n prevM)

_reconPath :: Connection -> PrevM -> Segment
_reconPath (s,curr) prevM = case Map.lookup curr prevM of
  Just prev -> if prev == s then [s] else prev : _reconPath (s,prev) prevM
  _         -> error "_reconPath reached unreachable case."
