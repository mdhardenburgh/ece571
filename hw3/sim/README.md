# Building and Running
To build the simulation, in this folder run:
- `$ cmake -S . -B build` to generate the makefiles.
- `$ cmake --build build` to build serialReciever simulation
- `$ ./serialReciever` to run the serialReciever simulation

# Usage
default input and output files are `serialReceiverInput.txt` and 
`serialReceiverOutput.txt`. A line in each file represents one clock cycle. A 
line for the input file contains 2 entries separated by a comma: the first entry 
is a serial in bit, and the second entry is a synchronous reset bit. A line for 
the output file also contains two entries also separated by a comma: First entry 
is parallel decimal output where X is a don't care, and the second entry is the 
done bit where 1 is done and 0 is not done.

Example input file:
```
1, 1
1, 0
1, 0
0, 0 // start bit
0, 0
0, 0
0, 0
0, 0
0, 0
0, 0
0, 0
1, 0
1, 0 // end bit
```

Example output file:
```
x, 0
x, 0
x, 0
x, 0 // start bit
x, 0
x, 0
x, 0
x, 0
x, 0
x, 0
x, 0
x, 0
1, 1 // end bit
```