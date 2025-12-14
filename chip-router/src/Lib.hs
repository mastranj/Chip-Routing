module Lib
    ( entryPoint
    ) where

import CRParallel.ParNegotiation
import CRParallel.ParNegotiationBatch
import CRParallel.ParNonoverlapGroups
import CRTypes.Types
import CRUtils.WriterFuncs
import CRUtils.Args
import Negotiation.BatchNegotiation
import Negotiation.Negotiation
import NetTools.NetOrderer
import NetTools.NetScorer
import NetTools.Partitioners.SlicePartitioner
import NetTools.InputProcessor
import System.Environment (getArgs, getProgName)
import System.Exit (die)

entryPoint :: IO ()
entryPoint = do
  args <- getArgs
  run args

run :: [String] -> IO ()
run [connFile, pf,pfInc,pfMax, hf, maxT,maxB, optN,optNL, parType, isBatch] = do
  let args = (connFile, read pf, read pfInc, read pfMax, read hf) :: Args
  showArgs args maxT maxB optN optNL parType isBatch
  contents <- readFile connFile

  let ls         = lines contents
  let nl         = toSegmentsIgnL "" ls (read maxT) (read maxB)
  let nl'        = optimNetsOrder (read optN) nl
  let nl''       = optimNLOrder (read optNL) nl'

  let parV       = (read parType) :: Int

  if parV == 3 then do
    putStrLn     $ "Running in parallel " ++ parType ++ ": Nonoverlapping batch"
    let routing  = parProblemsNegotiateRoute args nl''
    let score    = scoreRouting routing
    putStrLn     $ "Score: " ++ show score
    routingToX3D routing $ "output.par3." ++ show score++ ".x3d"

  else if parV == 2 then do
    putStrLn     $ "Running in parallel " ++ parType ++ ": Seq-Par Alternations"
    let routing  = parNegotiateRoute args nl''
    let score    = scoreRouting routing
    putStrLn     $ "Score: " ++ show score
    routingToX3D routing $ "output.par2." ++ show score++ ".x3d"

  else if parV == 1 then do
    putStrLn     $ "Running in parallel " ++ parType 
                   ++ ": Slice/netlist batching"
    let routing  = parNegotiateRouteB args nl''
    let score    = scoreRouting routing
    putStrLn     $ "Score: " ++ show score
    routingToX3D routing $ "output.par1." ++ show score++ ".x3d"

  else if read isBatch then do
    putStrLn     "Running batch (sequentially)"
    let nlPart   = partsByBounds 0 (0, 1200) (0, 1800) nl'' ((0,0),(9999,9999))
    let routing  = batchNegotiateRoute args nlPart
    let score    = scoreRouting routing
    putStrLn     $ "Score: " ++ show score
    routingToX3D routing $ "output.seq.batch." ++ show score++ ".x3d"

  else do
    putStrLn     "Running sequentially"
    let routing  = negotiateRoute args nl''
    let score    = scoreRouting routing
    putStrLn     $ "Score: " ++ show score
    routingToX3D routing $ "output.seq." ++ show score++ ".x3d"

  putStrLn "\n\nDone"
  
run _ = do
  progName <- getProgName
  die            $ "==== Usage: " ++ progName 
                 ++ " <inpFile> <pf> <pfInc> <pfMax> <hf> <maxTopPads> "
                 ++ "<maxBottomPads> <optimizeNets> <optimizeNetlists> "
                 ++ "<parType={0,1,2}> <isSeqBatch>"
