`include "riscvpkg.sv"

// WHY IS THERE NO STL IN SYSTEM VERILOG, AAAHHHHHHHHH!!!!!
function automatic int getNumLines(input string fname);
    int   fd;
    string line;
    int   numLines = 0;

  // open for reading
    fd = $fopen(fname, "r");

    while (!$feof(fd)) 
    begin
        if ($fgets(line, fd) != 0) 
        begin
            numLines++;
        end
    end

    $fclose(fd);
    return numLines;
endfunction

// filename.txt contains hex of instructions
module top #
(
    parameter string FILENAME = "filename.txt", 
    parameter int PARSE_ASSEMBLY = 0, 
    parameter string ASSEMBLER_PATH = "/opt/riscv/bin/riscv64-unknown-linux-gnu-as",
    parameter string OBJCPY_PATH = "/opt/riscv/bin/riscv64-unknown-linux-gnu-objcopy"
);
    logic[31:0]instrMemory[];
    int fd;
    initial
    begin
        ///logic[31:0]instrMemory[0:instrMemorySize-1];

        /* 
            if we want to automate the assembly and hex file creation,
            testing the riscvutil::disassemble against the assembler.
            For this to work FILENAME is literally just the name of the file 
            without the file extension such as ".s" or ".txt". 
        */
        if(PARSE_ASSEMBLY)
        begin
            instrMemory = new[getNumLines({FILENAME, ".s"}) - 1];
            fd = $fopen({FILENAME,".s"}, "r");
            $system({ASSEMBLER_PATH," -march=rv32i -mabi=ilp32 ",FILENAME,".s -o ", FILENAME,".o"});
            $system({OBJCPY_PATH," -O verilog --verilog-data-width=4 ",FILENAME,".o ",FILENAME,".hex"});
            $readmemh({FILENAME,".hex"}, instrMemory);
            
            for(int iIter = 0; iIter < instrMemory.size(); iIter++)
            begin
                string disassembledString = "invalid";
                string assemblyString = "empty";
                if(instrMemory[iIter] != 32'b0)
                begin
                    disassembledString = riscvutil::disassemble(instrMemory[iIter]);
                    $fgets(assemblyString, fd);

                    // strip trailing newline/carriage-return
                    if (assemblyString.len() > 0) 
                    begin
                        byte last = assemblyString[assemblyString.len()-1];
                        if (last == "\n" || last == "\r")
                            assemblyString = assemblyString.substr(0, assemblyString.len()-2);
                    end

                    if(assemblyString === disassembledString)
                    begin
                        `ifdef DEBUG
                        $display("dissassembly matches");
                        $display("disassembledString: %s", disassembledString);
                        $display("assemblyString:     %s", assemblyString);
                        `endif
                    end
                    else
                    begin
                        $display("dissassembly DOES NOT match");
                        $display("instrMemory[iIter]: %H", instrMemory[iIter]);
                        $display("disassembledString: %s", disassembledString);
                        $display("assemblyString:     %s", assemblyString);
                    end
                end
                else
                    break;
            end
        end
        else // just run riscvutil::disassemble() and print the output
        begin
            //static string assemblyFilename = {FILENAME, ".s"};
            instrMemory = new[getNumLines({FILENAME}) - 1];
            $readmemh(FILENAME, instrMemory);
            for(int iIter = 0; iIter < instrMemory.size(); iIter++)
            begin
                $display("0x%h: %s", instrMemory[iIter], riscvutil::disassemble(instrMemory[iIter]));
            end
        end
        $finish;
    end
endmodule