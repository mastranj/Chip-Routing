-- Similar to https://arxiv.org/html/2407.00009v1
-- Read the above after the fact, but thought it was interesting (RPTT-based)

module CRParallel.ParNegotiationBatch
    ( parNegotiateRouteB
    ) where
      
import Control.Parallel.Strategies
import CRParallel.ParAStarNetListAlg
import CRTypes.Types
import CRUtils.HelperFuncs
import NetTools.Partitioners.SlicePartitioner
import qualified Data.Map as Map

parNegotiateRouteB :: Args -> NetList -> Routing
parNegotiateRouteB args n = _parNegotiateRouteBOrg args 0 Map.empty n 500000

_parNegotiateRouteBOrg :: Args -> Int -> CostM -> NetList -> Int -> Routing
_parNegotiateRouteBOrg args i hcm ps sc = 
  _parNegotiateRouteBWork ps args i hcm psG sc
  where
    (stx, sty) = _getStep i
    bnds = ((0,0),(10000,10000))
    grps            = partsByBounds (_getOverlap i) (0, stx) (0, sty) ps bnds
    psG | i < 3     = grps ++ [[]]
        | otherwise = grps
  

_parNegotiateRouteBWork :: NetList -> Args -> Int -> CostM -> Problems -> Int 
                        -> Routing
_parNegotiateRouteBWork n args@(inp, pf, pfInc, pfMax, hf) i hcm ps minn
  | lofw == 0 = iter
  | otherwise = _parNegotiateRouteBOrg args' i' hcm' n min'
  where
    subPs           = take (length ps - 1) ps
    globalPs        = head $ drop (length ps - 1) ps
    globalIter      = parAStarNetList Map.empty hcm args globalPs
    globalOverflow  = seglistToCostM globalIter
    iters           = map (parAStarNetList globalOverflow hcm args) subPs 
                        `using` parList rdeepseq
    iter            = (concat iters) ++ globalIter
    overflow        = getOverflow iter
    lofw            = length overflow
    hcm'            = getNextCost overflow hcm hf
    pf'             = min pfMax $ pf * pfInc
    pfInc'          = pfInc
    i'              = succ i
    min'            = min lofw minn
    args'           = (inp, pf', pfInc', pfMax, hf)      

_getOverlap :: Int -> Int
_getOverlap i | i < 4     = 70
              | i < 7     = 100
              | i < 9     = 50
              | otherwise = 0

_getStep :: Int -> (Int, Int)
_getStep i | i < 2     = (1100, 5000)
           | i < 5     = (5000, 600)
           | i < 10    = (700, 1800)
           | i < 15    = (1400, 1800)
           | otherwise = (8500, 8500)