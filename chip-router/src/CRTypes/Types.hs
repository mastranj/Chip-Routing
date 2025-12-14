module CRTypes.Types
    ( Connection, Net, NetList, Coord, Segment, SegmentList, Routing,
      Bounds, PrevM, Direction(..), MaybeDirection(..), Problems,
      CostM, Cost, CoordRep, Neighbors, CostMKey,
      Args
    ) where

import qualified Data.Map as Map

type ArgInpFile     = String
type ArgPf          = Double
type ArgPfInc       = Double
type ArgMaxPf       = Double
type ArgHf          = Double
type Args           = (ArgInpFile, ArgPf, ArgPfInc, ArgMaxPf, ArgHf)

type Cost           = Double
type CostMKey       = Int
type CostM          = Map.Map CostMKey Cost

type PrevM          = Map.Map Coord Coord

data MaybeDirection = DViaUp | DViaDown
data Direction      = DLeft | DRight | DUp | DDown

type X              = Int
type Y              = Int
type Layer          = Int
type CoordRep       = Int

type Bounds         = ((X,Y), (X,Y))

type Connection     = (Coord, Coord)
type Net            = [Connection]
type NetList        = [Net]
type Problems       = [NetList]

type Coord          = (X, Y, Layer)
type Neighbors      = [Coord]

type Segment        = [Coord]
type SegmentList    = [Segment]
type Routing        = [SegmentList]
