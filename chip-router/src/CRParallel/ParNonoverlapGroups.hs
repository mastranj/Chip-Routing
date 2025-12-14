module CRParallel.ParNonoverlapGroups
    ( parProblemsNegotiateRoute
    ) where
      
import Control.Parallel.Strategies
import CRParallel.ParAStarNetAlg
import CRParallel.ParAStarNetListAlg
import CRTypes.Types
import CRUtils.HelperFuncs
import NetTools.NetOrderer
import NetTools.Partitioners.OverlapPartitioner
import qualified Data.Map as Map


parProblemsNegotiateRoute :: Args -> NetList -> Routing
parProblemsNegotiateRoute a nl = _parProblemsNegotiateRoute a Map.empty sp gp
  where
    ov    = 150
    lim   = 3
    ps    = partsByNonOverlap ov nl
    subP  = take (length ps - 1) ps
    gp    = optimNLOrder True $ concat $ 
              (drop (length ps - 1) ps) ++ (filter (\x -> length x <= lim) subP)
    sp    = map (\x -> optimNLOrder True x) $ filter (\x -> length x > lim) subP

_parProblemsNegotiateRoute :: Args -> CostM -> Problems -> NetList -> Routing
_parProblemsNegotiateRoute args@(inp, pf, pfInc, pfMax, hf) hcm ps globalPs
  | lofw == 0  = allIters
  | otherwise  = _parProblemsNegotiateRoute args' hcm' ps globalPs
  where
    globalIter = parAStarNetList Map.empty hcm args globalPs
    otherIters = _processProblems ps args (seglistToCostM globalIter) hcm
    allIters   = globalIter ++ otherIters
    overflow   = getOverflow allIters
    lofw       = length overflow
    hcm'       = getNextCost overflow hcm hf
    pf'        = min pfMax $ pf * pfInc
    args'      = (inp, pf', pfInc, pfMax, hf)

_processProblems :: Problems -> Args -> CostM -> CostM -> Routing
_processProblems [] _ _ _ = []
_processProblems (nl:nls) args pOcm hcm = next ++ iter
  where
    iter  = map (parAStarNet pOcm hcm args) nl 
                `using` parList rdeepseq :: Routing
    pOcm' = Map.unionWith (+) pOcm (seglistToCostM iter)
    next  = _processProblems nls args pOcm' hcm