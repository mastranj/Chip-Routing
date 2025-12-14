module Negotiation.BatchNegotiation
    ( batchNegotiateRoute
    ) where
      
import CRParallel.ParAStarNetListAlg
import CRTypes.Types
import CRUtils.HelperFuncs
import qualified Data.Map as Map

batchNegotiateRoute :: Args -> Problems -> Routing
batchNegotiateRoute args n = _batchNegotiateRoute args Map.empty Map.empty n

_batchNegotiateRoute :: Args -> CostM -> CostM -> Problems -> Routing
_batchNegotiateRoute args@(inp, pf, pfInc, pfMax, hf) pOcm hcm ps
  | lofw == 0 = (concat (map (snd) iters)) ++ gIter
  | otherwise = _batchNegotiateRoute args' overflow hcm' ps
  where
    subPs         = take (length ps - 1) ps
    globalPs      = head $ drop (length ps - 1) ps
    (gOcm, gIter) = 
      parAStarNetListBatch pOcm hcm (inp, pf, pfInc, pfMax, 2*hf) globalPs
    iters         = map (parAStarNetListBatch gOcm hcm args) subPs
    overflow      = Map.filter (\v -> v > 0) $ 
                      Map.fromList $ map (\(k,v) -> (k,v-1)) $ Map.toList $ 
                      foldl (\acc n -> Map.unionWith (+) acc n) 
                      gOcm (map (fst) iters)
    lofw          = length overflow
    hcm'          = getNextCost overflow hcm hf
    pf'           = min pfMax $ pf * pfInc
    pfInc'        = pfInc
    args'         = (inp, pf', pfInc', pfMax, hf)   