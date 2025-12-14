module Negotiation.AStarNetListAlg
    ( aStarNetList, aStarNetListH
    ) where

import CRTypes.Types
import CRUtils.HelperFuncs (accumulateOverflowFromIter)
import CRUtils.Heuristics
import Negotiation.AStarNetAlg

aStarNetListH :: H -> CostM -> CostM -> Args -> NetList -> Routing
aStarNetListH _ _ _ _ []           = []
aStarNetListH h om hcm args (n:nl) = solvedNet : aStarNetListH h om' hcm args nl
  where
    solvedNet = aStarNetH h om hcm args n
    om'       = accumulateOverflowFromIter om [solvedNet]

aStarNetList :: CostM -> CostM -> Args -> NetList -> Routing
aStarNetList  = aStarNetListH manhattan3DBounded