module CRParallel.ParAStarNetAlg
    ( parAStarNet, parAStarNetH
    ) where

import Control.Parallel.Strategies
import CRTypes.Types
import CRUtils.Heuristics
import Negotiation.AStarConnAlg

parAStarNetH :: H -> CostM -> CostM -> Args -> Net -> SegmentList
parAStarNetH h om hcm args nl
  | length nl <= 3  = _parAStarNetH h om hcm args nl
  | otherwise       = map (aStarConnH h om hcm args) nl `using` parList rdeepseq

_parAStarNetH :: H -> CostM -> CostM -> Args -> Net -> SegmentList
_parAStarNetH _ _ _ _ []           = []
_parAStarNetH h om hcm args (n:nl) = solvedConn : _parAStarNetH h om hcm args nl
  where solvedConn                 = aStarConnH h om hcm args n

parAStarNet :: CostM -> CostM -> Args -> Net -> SegmentList
parAStarNet = parAStarNetH manhattan3DBounded