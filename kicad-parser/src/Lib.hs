-- With the help of Professor Edwards, this project was created
-- to parse SExpressions and cad files for PCB routing
-- Collaborators: Professor Edwards

module Lib
    ( entryPoint
    ) where

import System.Environment (getArgs, getProgName)
import System.Exit (die)
import SExpr
import ProcessSExpr
import Utils
import SvgGenerator
import FileCleaner

entryPoint :: IO ()
entryPoint = do
  args <- getArgs
  run  args

run :: [String] -> IO ()
run [f, out1, mm]              = do
  let path1                    = "output/" ++ out1 ++ ".fulldetails.txt"
  let path2                    = "output/" ++ out1 ++ ".cleaned.txt"
  let path3                    = "output/" ++ out1 ++ ".svg"
  
  let mmD                      = round (1 / (toDble mm))

  writeFile path1 "" -- clean the file out
  writeFile path2 "" -- clean the file out

  contents                    <- readFile f
  let cleanContents           = [ c | c <- contents, c /= '\r' && c /= '\n' ]

  generateNetPoints mmD path1 $ parseSExpr cleanContents
  (coords, groupedNetList)    <- cleanFile path1 path2
  let roundingError           = 200
  let minX                    = getExtremeX min 100000 coords
  let minY                    = getExtremeY min 100000 coords
  let maxX                    = getExtremeX max 0 coords
  let maxY                    = getExtremeY max 0 coords
  let maxX'                   = maxX-minX+roundingError
  let maxY'                   = maxY-minY+roundingError

  generateSvg path3 (roundingError,minX,maxX',minY,maxY') groupedNetList
  putStrLn "Done"
run _   = do
  progName <- getProgName
  die $ "\n == Usage: " ++ progName 
      ++ " <file_to_parse> <out_filename> <mm_in_decimal>\n"