module Types
    ( SExpr(..), MDouble, TripleD, PairD, PairS, NetInfo,
      PairI, NetRep
    ) where

data SExpr             = Atom String | SExpr [SExpr] deriving (Show)
type MDouble           = Maybe Double
type TripleD           = (Double, Double, Double)
type PairD             = (Double, Double)
type PairS             = (String, String)
type PairI             = (Int, Int)
--   NetInfo             (nid,    name,   x,      y,      t,      layers)
type NetInfo           = (String, String, Double, Double, Double, String)
--   NetRep              (nid,   x,   y,   name,   layer )
type NetRep            = (String, Int, Int, String, String)