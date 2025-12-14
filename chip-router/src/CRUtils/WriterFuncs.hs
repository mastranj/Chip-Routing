-- Used https://doc.x3dom.org/tutorials/models/aopt/index.html and
-- https://www.x3dom.org/ generally to learn about x3dom
module CRUtils.WriterFuncs
    ( segmentToX3D, segmentListToX3D, routingToX3D
    ) where

import CRTypes.Types
import Data.List.Split (splitOn)

type ColorSet = (Double, Double, Double)

routingToX3D :: Routing -> String -> IO ()
routingToX3D s f = do
  let f'     = "output/" ++ f
  _x3dHeader f'
  _procRoutingToX3D (1,1,1) s f'
  _x3dFooter f'
  putStrLn   $ "Generated " ++ f' ++ "!"

_procRoutingToX3D :: ColorSet -> Routing -> String -> IO ()
_procRoutingToX3D _ [] _     = return ()
_procRoutingToX3D c (s:ls) f = do
  _procSegmentListToX3D s c f
  _procRoutingToX3D (_getColor c) ls f

_getColor :: ColorSet -> ColorSet
_getColor (r,g,b) = 
  (bounded (r+0.223), bounded (g+0.1564), bounded (b+0.2519))
  where 
    bounded x
      | x > 1.0   = bounded (x-1.0)
      | otherwise = x

_toColorSet :: String -> ColorSet
_toColorSet s = case splitOn " " s of
  (r:g:b:[]) -> (read r, read g, read b)
  _          -> (1,1,1)

_toClr :: ColorSet -> String
_toClr (r,g,b) = show r ++ " " ++ show g ++ " " ++ show b

segmentListToX3D :: SegmentList -> String -> IO ()
segmentListToX3D s f = do
  let f'     = "output/" ++ f
  _x3dHeader f'
  _procSegmentListToX3D s (1,1,1) f'
  _x3dFooter f'
  putStrLn   $ "Generated " ++ f' ++ "!"

_procSegmentListToX3D :: SegmentList -> ColorSet -> String -> IO ()
_procSegmentListToX3D [] _ _ = return ()
_procSegmentListToX3D (s:ls) eCol f = do
  _x3dSegment s f eCol
  _procSegmentListToX3D ls eCol f

segmentToX3D :: Segment -> String -> IO ()
segmentToX3D s f = do
  let f'      = "output/" ++ f
  _x3dHeader  f'
  _x3dSegment s f' (1, 1, 1)
  _x3dFooter  f'
  putStrLn    $ "Generated " ++ f' ++ "!"

_x3dSegment :: Segment -> String -> ColorSet -> IO ()
_x3dSegment s f c = do
  appendFile f    "\t\t<Shape>\n"
  appendFile f    "\t\t\t<Appearance>\n"
  appendFile f $  "\t\t\t\t<Material emissiveColor = \"" ++ _toClr c ++ "\"/>\n"
  appendFile f    "\t\t\t</Appearance>\n"
  appendFile f $  "\t\t\t<LineSet vertexCount=\"" ++ show (length s) ++ "\">\n"
  appendFile f $  "\t\t\t\t<Coordinate point=\"" ++ _getLine s ++ "\" />\n"
  appendFile f $  "\t\t\t</LineSet>\n"
  appendFile f    "\t\t</Shape>\n"
      
_getLine :: Segment -> String
_getLine [] = ""
_getLine ((x,y,l):sls) = 
  (show x) ++ " " ++ (show l) ++ " " ++ (show y) ++ "  " ++ _getLine sls


_x3dHeader :: String -> IO ()
_x3dHeader f = do
  writeFile  f ""
  appendFile f "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  appendFile f "<X3D profile=\"Interchange\" version=\"3.3\">\n"
  appendFile f "\t<Scene>\n"
  appendFile f "\t<Viewpoint position =\"0 0 0\"/>\n"

_x3dFooter :: String -> IO ()
_x3dFooter f = do
  appendFile f "\t</Scene>\n"
  appendFile f "</X3D>\n"
