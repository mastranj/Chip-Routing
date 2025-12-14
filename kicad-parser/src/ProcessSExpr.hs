module ProcessSExpr
    ( generateNetPoints
    ) where

import Types
import Utils

generateNetPoints :: Int -> String -> SExpr -> IO ()
generateNetPoints scale f (SExpr s) = do
  _generateNetPoints scale f s
  putStrLn $ "Generated " ++ f

generateNetPoints _ _ _ = error "Bad SExpr to start generating from."

_generateNetPoints :: Int -> String -> [SExpr] -> IO ()
_generateNetPoints scale f (Atom "module":ls)    = _processModule scale f ls
_generateNetPoints scale f (Atom "footprint":ls) = _processModule scale f ls
_generateNetPoints scale f (SExpr s:ls) = do
  _generateNetPoints scale f s
  _generateNetPoints scale f ls
_generateNetPoints scale f (_:ls)                = _generateNetPoints scale f ls
_generateNetPoints _ _ []                        = return ()

_processModule :: Int -> String -> [SExpr] -> IO ()
_processModule scale f s = do
  let netInfos = _findPadNets s
  let moduleAt = _findAt s
  printModule scale f netInfos moduleAt

printModule :: Int -> String -> [NetInfo] -> TripleD -> IO ()
printModule _ _ [] _ = return ()
printModule scale f ((nid, name, x, y, _, layers):ls) moduleAt = do
  let (x',y') = scaleCoord scale $ toGlbalPos moduleAt (x,y)
  appendFile f $ unwords [nid, show x', show y', name, layers]
  appendFile f "\n"
  printModule scale f ls moduleAt

_findAt :: [SExpr] -> TripleD
_findAt (SExpr (Atom "at":Atom x: [Atom y]):_)         = 
  (read x, read y, 0)
_findAt (SExpr (Atom "at":Atom x: Atom y: [Atom t]):_) = 
  (read x, read y, read t)
_findAt (_:ls)                                         = _findAt ls
_findAt []                                             = 
  error $ "At cannot be found"

_findPadNets :: [SExpr] -> [NetInfo]
_findPadNets (SExpr (Atom "pad":pd):ls)
  | _badNet == n    = _findPadNets ls
  | otherwise       = (nid, name, x, y, t, layers) : _findPadNets ls
  where
    (x,y,t)         = _findAt pd
    n@(nid,name)    = _findNets pd
    layers          = _findLayer pd
_findPadNets (_:ls) = _findPadNets ls
_findPadNets []     = []

_findLayer :: [SExpr] -> String
_findLayer (SExpr (Atom "layers":Atom l1:Atom l2:Atom l3:_):_) = 
  unwords [l1,l2,l3]
_findLayer (_:ls) = _findLayer ls
_findLayer []   = ""

_findNets :: [SExpr] -> PairS
_findNets (SExpr (Atom "net":Atom nid:[Atom name]):_) = (nid,name)
_findNets (_:ls)                                      = _findNets ls
_findNets []                                          = _badNet

_badNet :: PairS
_badNet = ("","")