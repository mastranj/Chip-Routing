-- followed https://dl.acm.org/doi/pdf/10.1145/201310.201328
module Negotiation.Negotiation
    ( negotiateRoute, _negotiateRoute
    ) where

import CRTypes.Types
import CRUtils.HelperFuncs
import Negotiation.AStarNetListAlg
import qualified Data.Map as Map

negotiateRoute :: Args -> NetList -> Routing
negotiateRoute args n = _negotiateRoute args Map.empty n

_negotiateRoute :: Args -> CostM -> NetList -> Routing
_negotiateRoute args@(inp, pf, pfInc, pfMax, hf) hcm nl
  | lofw == 0    = iter
  | otherwise    = _negotiateRoute args' hcm' nl
  where
    iter         = aStarNetList Map.empty hcm args nl
    overflow     = getOverflow iter
    (lofw, hcm') = (length overflow, getNextCost overflow hcm hf)
    pf'          = min pfMax $ pf * pfInc
    args'        = (inp, pf', pfInc, pfMax, hf)          