-- https://ceca.pku.edu.cn/media/lw/f8937474bc4352fa545e32f55ae8e7be.pdf 
-- mentions partitioning with nonoverlapping bouding boxes and run those
-- in parallel. They cite https://dl.acm.org/doi/10.1145/2435264.2435322
-- which I am unable to access.
module CRParallel.ParNegotiation
    ( parNegotiateRoute
    ) where
      
import Control.Parallel.Strategies
import CRParallel.ParAStarNetListAlg
import CRParallel.ParAStarNetAlg
import CRTypes.Types
import CRUtils.HelperFuncs
import NetTools.Partitioners.SlicePartitioner
import qualified Data.Map as Map

parNegotiateRoute :: Args -> NetList -> Routing
parNegotiateRoute a n = _parNegotiateRoute 100000 0 a Map.empty Map.empty n

_parNegotiateRoute :: Int -> Int -> Args -> CostM -> CostM -> NetList -> Routing
_parNegotiateRoute psc i args@(inp, pf, pfInc, pfMax, hf) pOcm hcm n
  | lofw == 0 = iter
  | isNextPar = _parNegotiateRoute lofw (succ i) args' overflow hcm' n
  | otherwise = _parNegotiateRoute lofw (succ i) args' Map.empty hcm' n
    where
      isParRun :: Int -> Int -> Bool
      isParRun sc it = it `mod` 2 /= 0 && sc > 15

      isPar                 = isParRun psc i
      isNextPar             = isParRun psc $ i + 1
      ps       | isPar      = toGroupsSizeN _getGroupS n
               | otherwise  = [n]
      usedArgs | isPar      = (inp, pf*0.5, pfInc, pfMax, hf*2)
               | otherwise  = args
      lps                   = (length ps > 1)
      iter                  = _processProblems ps lps usedArgs pOcm hcm
      overflow              = getOverflow iter
      lofw                  = length overflow
      hcm'                  = getNextCost overflow hcm hf
      pf'                   = min pfMax $ pf * pfInc
      args'                 = (inp, pf', pfInc, pfMax, hf)

_getGroupS :: Int
_getGroupS = 25

_processProblems :: Problems -> Bool -> Args -> CostM -> CostM -> Routing
_processProblems [] _ _ _ _ = []
_processProblems (nl:nls) isPar args pOcm hcm
  | not isPar = parAStarNetList pOcm hcm args nl
  | otherwise = next ++ iter
  where
    iter     = map (parAStarNet pOcm hcm args) nl 
                `using` parList rdeepseq :: Routing
    pOcm'    = _accumulateCost pOcm $ iter
    next     = _processProblems nls isPar args pOcm' hcm

_accumulateCost :: CostM -> Routing -> CostM
_accumulateCost om []                 = om
_accumulateCost om (solvedNet:others) = _accumulateCost c others
  where c = accumulateOverflowFromIter om [solvedNet]