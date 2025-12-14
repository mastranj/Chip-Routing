module NetTools.NetScorer
    ( scoreRouting
    ) where

import CRTypes.Types (Routing)

scoreRouting :: Routing -> Int
scoreRouting r = length $ concat $ concat r
