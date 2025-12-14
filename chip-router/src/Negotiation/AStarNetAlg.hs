module Negotiation.AStarNetAlg
    ( aStarNet, aStarNetH
    ) where

import CRTypes.Types
import CRUtils.Heuristics
import Negotiation.AStarConnAlg

aStarNetH :: H -> CostM -> CostM -> Args -> Net -> SegmentList
aStarNetH _ _ _ _ []           = []
aStarNetH h om hcm args (n:nl) = solvedConn : aStarNetH h om hcm args nl
  where solvedConn             = aStarConnH h om hcm args n

aStarNet :: CostM -> CostM -> Args -> Net -> SegmentList
aStarNet = aStarNetH manhattan3DBounded