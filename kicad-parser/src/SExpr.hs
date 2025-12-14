module SExpr
    ( parseSExpr, SExpr(..)
    ) where

import Types

parseSExpr :: String -> SExpr
parseSExpr             = fst . _parseSExpr

_parseSExpr :: String -> (SExpr, String)
_parseSExpr ('\"':ls)  = parseQuote ls
_parseSExpr ('(':ls)   = (SExpr l, ls2)
  where
    (l,ls2) = getLs ls
    getLs :: String -> ([SExpr],String)
    getLs (')':x)      = ([],x)
    getLs (' ':x)      = getLs x
    getLs x            = (s : ll, lss)
      where
        (ll, lss) = getLs st
        (s,st) = _parseSExpr x
_parseSExpr (')':_)    = error $ "Bad SExpr"
_parseSExpr (' ':ls)   = _parseSExpr ls
_parseSExpr []         = error $ "Bad example"
_parseSExpr s          = parseAtom s

parseQuote :: String -> (SExpr, String)
parseQuote s           = (Atom s1,tail s2)
  where 
    (s1,s2) = span (isQuoteChar) s
    isQuoteChar :: Char -> Bool
    isQuoteChar '\"'  = False
    isQuoteChar _     = True

parseAtom :: String -> (SExpr, String)
parseAtom s           = (Atom s1,s2)
  where 
    (s1,s2)           = span (isAtomChar) s
    isAtomChar :: Char -> Bool
    isAtomChar '('    = False
    isAtomChar ')'    = False
    isAtomChar ' '    = False
    isAtomChar _      = True