# chip-router

Big thanks to Professor Edwards for advising this project and helping me
learn about chips, routing, and Haskell!


## To run benchmarks

1. Sequential:

> time stack run sample_assets/hdmi2usb.subset.txt 1 1.5 1000 1 2 400 True True 0 False

2. Sequential batched:

> time stack run sample_assets/hdmi2usb.subset.txt 1 1.5 1000 1 2 400 True True 0 True

3. Parallel variation 1: Parallel-Netlists

> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N1 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N2 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N3 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N4 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N5 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N6 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N7 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N8 -l

3. Parallel variation 2: Sequential-Parallel Alternating

> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N1 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N2 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N3 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N4 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N5 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N6 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N7 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N8 -l

3. Parallel variation 3: Non-overlapping Parallel Batches

> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N1 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N2 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N3 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N4 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N5 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N6 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N7 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N8 -l

## How this project was generated
This project was generated using the following commands:
> stack new chip-router

## Input
Use the Kicad-Parser project to parse a KiCAD PCB file (expecting S-Expression
as the representation). Use any of the *.cleaned.txt files as input here. It is
suggested to use the *.onelayer.txt files.

Additionally, there are provided sample_assets that are expected to be used as
the files located in this folder have been tested.

## Arguments
The following is a description of arguments, in the order they are expected.
Please see Types.hs for the type signature of Args. If you run the program
without any arguments, the following help message will be displayed:
```
==== Usage: chip-router-exe <inpFile> <pf> <pfInc> <pfMax> <hf> <maxTopPads> 
<maxBottomPads> <optimizeNets> <optimizeNetlists> <parType={0,1,2}> <isSeqBatch>
```

The following is a brief explanation of each:

1. **inpFile** - Input file from the kicad-parser. See sample_assets folder
                  for example input files to use (e.g. `hdmi2usb.subset.txt`).
2. **pf** - present factor, affects how much weight is given to present overuse.
   Sample value (0.6)
3. **pfInc** - pres fac increase, multiples pf by this value each iteration.
   Sample value (1.003)
4. **pfMax** - caps the maximum pf value. Sample value (4).
5. **hf** - historical factor, affects how much weight is given to historical
   overuse. Sample value (1)
6. **maxTopPads** - Maximum number of pads per nets found in the top layer (2).
7. **maxBottomPads** - Maximum number of pads per nets found in the bottom
                       layer (400).
8. **optimizeNets** - Applies optimizations at the net-level. This will prevent
  a naive solution and low quality output. It will also decrease runtime and
  provide stability to convergence. It creates a MST-like list of connections 
  trying to minimize the length between connections. Sample values <True|False>

   Note: Suggested to/Must be set to false when/for parallelization.
7. **optimizeNetlists** - Optimizes the netlist ordering by placing the 
"most difficult" nets to be solved first thus allowing them to claim paths 
first. Sample values <True|False>
8. **parType** - Is an integer value. Given a value of 1, it will run the first
variation of parallel execution for chip routing. 2 Will run the second
variation. Any other value will result in running non-parallel execution.
  - **0** - Run sequentially
  - **1** - First variation which tries to find groups of netlists to run in
  parallel. These groups are netlists that are completed contained within some
  bounding box. Any net that does not get grouped will belong to a special 
  group of nets that is run sequentially.
    - Run with `stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 1 False -- +RTS -N2 -l`
  - **2** - Second variation which alternates between sequential execution and
  parallel execution on random slices. For the random slices in parallel, it
  will run n (typically 25) nets in parallel, sum their present usage, and
  continue on the next 25.
    - Run with `stack run sample_assets/hdmi2usb.subset.txt 1 1.5 1000 1 2 400 True True 2 False -- +RTS -N2 -l`
9. **isSeqBatch** - If true, and if isPar is false, then this will run a 
sequential batched version. <True|False>


## How to run
You can run this program in sequential, sequential batch,
parallel variation 1, parallel variation 2, parallel variation 3
respectively, by the following commands:


```
> stack build
> stack run sample_assets/hdmi2usb.subset.txt 1 1.5 1000 1 2 400 True True 0 False
> stack run sample_assets/hdmi2usb.subset.txt 1 1.5 1000 1 2 400 True True 0 True
> stack run sample_assets/hdmi2usb.subset.txt 1 1.55 1000 1 2 400 True True 1 False -- +RTS -N1 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.28 1000 1 2 400 True True 2 False -- +RTS -N1 -l
> stack run sample_assets/hdmi2usb.subset.txt 1 1.4 12000 0.9 2 400 True True 3 False -- +RTS -N2 -l
```

If no or an incorrect number of arguments is provided, a help message
will be printed out with correct arguments expected. See the section in this
readme for "Example run".


## Output
- Any output can be found in the output/folder
 - If one does not exist, please make one (e.g. `mkdir output`)
- Each successful run generates a "output.x3d" file in the output folder.


## X3D
- Some of the outputs will be `.x3d` files. To render these files, you can
 open a web browser and navigate to the file on your local machine. If VSCode
 is used, the "X_ITE VS Code Extension" plugin can be used to render them
 and helps ensure the viewpoint is correct/moveable.

## References
1. https://dl.acm.org/doi/pdf/10.1145/201310.201328 - base for neg cong alg
2. http://www.ecs.umass.edu/ece/tessier/fpd98.pdf - A* modification in cong alg
3. https://docs.verilogtorouting.org/en/latest/vpr/command_line_usage/ - Defaults the pres fac mult to 1.3
4. https://en.wikipedia.org/wiki/A*_search_algorithm
5. https://www.seas.upenn.edu/~andre/courses/EDA/slides/day14_6up.pdf
6. http://www.ecs.umass.edu/ece/tessier/fpd98.pdf
7. https://www.researchgate.net/publication/243558701_Development_of_a_Place_and_Route_Tool_for_the_RaPiD_Architecture