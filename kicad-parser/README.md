# chip-router

Big thanks to Professor Edwards for advising this project and helping with the
S-Expression parser.

## How this project was generated
This project was generated using the following commands:
> stack new kicad-parser

## How to run
You can run this program by the following commands:
```
> stack build
> stack run <args>
```

Note to self: can add `-- +RTS -N2` onto `stack run`

## Arguments
when using `stack run <args>` the following is the expected usgage:

> `stack run`
> `== Usage: kicad-parser-exe <file_to_parse> <out_filename> <mm_in_decimal>`

Where:
- `<file_to_parse>` is the kicad_pcb file to read data from

- `<out_filename>` is the base file name to use when generating output into
  the `output/` directory. This typically will generate a few `.txt` and `.svg`.
  The `.svg` is used to visualize the graph. The `.txt`s should be used
  with the other haskell project to calculate routes. The provided filename
  should not be given with file extension (e.g. do not provide `out_filename`
  as "outputfile.txt", rather "outputfile").

- `<mm_in_decimal>` is the scaling factor. For example, 0.1 is a 0.1mm board
  and will multiply by 10 = (1/0.1) and round for each x/y coordinate.

A successful run looks like:
> james@DESKTOP-xx:~/haskell/project/code/kicad-parser$ <b>stack run assets/HDMI2USB.kicad_pcb hdmi2 0.1</b>

> Generated output/test_hdmi2.fulldetails.txt

> Generated output/test_hdmi2.cleaned.txt and output/test_hdmi2.cleaned.txt.onelayer.txt

> Generated output/test_hdmi2.svg

> Done

## Output
Is placed in the output/ folder. The *.cleaned.txt outputs should be used as 
input to the chip routing project.


## Readings
- For kicad file formats and S-Expr:
  - https://dev-docs.kicad.org/en/file-formats/sexpr-intro/index.html
- Rotations:
  - https://en.wikipedia.org/wiki/Rotation_matrix
- Degrees to radians
  - https://en.wikipedia.org/wiki/Radian