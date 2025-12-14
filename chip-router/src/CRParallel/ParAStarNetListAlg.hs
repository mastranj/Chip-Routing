module CRParallel.ParAStarNetListAlg
    ( parAStarNetListBatch, parAStarNetList
    ) where

import CRParallel.ParAStarNetAlg
import CRTypes.Types
import CRUtils.HelperFuncs
import CRUtils.Heuristics

parAStarNetListH :: H -> CostM -> CostM -> Args -> NetList -> Routing
parAStarNetListH _ _ _ _ [] = []
parAStarNetListH h om hcm args (n:nl) = 
  solvedNet : parAStarNetListH h om' hcm args nl
  where
    solvedNet = parAStarNetH h om hcm args n
    om'       = accumulateOverflowFromIter om [solvedNet]

parAStarNetList :: CostM -> CostM -> Args -> NetList -> Routing
parAStarNetList om hcm args nl         =
  parAStarNetListH manhattan3DBounded om hcm args nl

parAStarNetListBatch :: CostM -> CostM -> Args -> NetList -> (CostM, Routing)
parAStarNetListBatch om hcm args nl    = (seglistToCostM ans, ans)
  where ans = parAStarNetListH manhattan3DBounded om hcm args nl