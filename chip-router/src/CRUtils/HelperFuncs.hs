module CRUtils.HelperFuncs
    ( getAllNeighbors, getNextCost, getCost, getCostD, 
      coordToInt, intToCoord, _coordToInt, _intToCoord,
      getOverflow, accumulateOverflowFromIter, coordToCostMKey, 
      insertCostM, fromListCostM, layers, seglistToCostM
    ) where
      
import CRTypes.Types
import qualified Data.Map as Map
import qualified Data.Set as Set

layers :: Int
layers = 1

-- Neighbor handling
getAllNeighbors :: Coord -> Neighbors
getAllNeighbors c = case (vU, vD) of
  (Nothing, Just vdv) -> [u, d, l, r, vdv]
  (Just vuv, Nothing) -> [u, d, l, r, vuv]
  _                   -> error $ "Reached unreachable (neigh) for " ++ show c
  where
    u                  = _getNextDir      c DUp
    d                  = _getNextDir      c DDown
    l                  = _getNextDir      c DLeft
    r                  = _getNextDir      c DRight
    vU                 = _getNextMaybeDir c DViaUp
    vD                 = _getNextMaybeDir c DViaDown

_getNextMaybeDir :: Coord -> MaybeDirection -> Maybe Coord
_getNextMaybeDir (x,y,l) DViaUp
  | l < layers                = Just (x,y,l+1)
  | otherwise                 = Nothing
_getNextMaybeDir (x,y,l) DViaDown
  | l > 0                     = Just (x,y,l-1)
  | otherwise                 = Nothing

_getNextDir :: Coord -> Direction -> Coord
_getNextDir (x,y,l) DUp      = (x,y+1,l)
_getNextDir (x,y,l) DDown    = (x,y-1,l)
_getNextDir (x,y,l) DLeft    = (x-1,y,l)
_getNextDir (x,y,l) DRight   = (x+1,y,l)

-- Get costs from [CostM]
getCost :: CostM -> Coord -> Cost -- To be used for board costs
getCost c cm = max 0 $ (getCostD 1 c cm) - 1

getCostD :: Cost -> CostM -> Coord -> Cost
getCostD d cm coord = case Map.lookup (coordToCostMKey coord) cm of
  Nothing      -> d
  (Just cost)  -> cost

-- Calculate overflow operations
accumulateOverflowFromIter :: CostM -> Routing -> CostM
accumulateOverflowFromIter iCm sl = _calcOverflow 1 iCm (_getSetCoordList sl)

getOverflow :: Routing -> CostM
getOverflow sl = 
  Map.filter (\v -> v > 0) $ _calcOverflow 0 Map.empty (_getSetCoordList sl)

seglistToCostM :: Routing -> CostM
seglistToCostM sl = Map.filter (\v -> v > 0) $ 
                      _calcOverflow 1 Map.empty (_getSetCoordList sl)

_getSetCoordList :: Routing -> [Set.Set Coord]
_getSetCoordList []     = []
_getSetCoordList (s:ls) = (_flattenedSToSet (_flattenSegmentL s)) :
                            _getSetCoordList ls

_flattenSegmentL :: SegmentList -> Segment
_flattenSegmentL []     = []
_flattenSegmentL (s:ls) = s ++ _flattenSegmentL ls

_flattenedSToSet :: Segment -> Set.Set Coord
_flattenedSToSet = Set.fromList

_calcOverflow :: Double -> CostM -> [Set.Set Coord] -> CostM
_calcOverflow _ cm []       = cm
_calcOverflow def cm (s:ls) = _calcOverflow def (process cm (Set.toList s)) ls
  where
    process :: CostM -> [Coord] -> CostM
    process m [] = m
    process m (c:cs) = process (case Map.lookup intC m of
      Nothing -> Map.insert intC def m
      Just v  -> Map.insert intC (succ v) m) cs
      where
        intC = coordToCostMKey c

-- Get next historical cost from current hcm and present usgae [CostM]s
getNextCost :: CostM -> CostM -> Double -> CostM
getNextCost ocm hcm fac = Map.unionWith (getNewHCost) ocm hcm
  where
    getNewHCost :: Cost -> Cost -> Cost
    getNewHCost oc hc   = oc*fac + hc

_safeMax :: Int
_safeMax = 9000

coordToInt :: Coord -> CoordRep
coordToInt c = _coordToInt c _safeMax

_coordToInt :: Coord -> Int -> CoordRep
_coordToInt (x,y,l) maxLen = x + y * safeM + safeM*safeM * l
  where safeM = maxLen + 1

intToCoord :: CoordRep -> Coord
intToCoord n = _intToCoord n _safeMax

_intToCoord :: CoordRep -> Int -> Coord
_intToCoord n maxLen = (x, y, l)
  where
    safeM = maxLen + 1
    ml2   = safeM * safeM
    l     = n `div` ml2
    lml2  = l * ml2
    y     = (n - lml2) `div` safeM
    x     = n - lml2 - y * safeM

coordToCostMKey :: Coord -> CostMKey
coordToCostMKey = coordToInt

fromListCostM :: [(Coord, Cost)] -> CostM
fromListCostM ls =  Map.fromList ls'
  where ls' = map (\(k,c) -> (coordToCostMKey k,c)) ls

insertCostM :: Coord -> Cost -> CostM -> CostM
insertCostM c = Map.insert (coordToCostMKey c)