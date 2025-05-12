`include "riscvpkg.sv"

module top;
    parameter instrMemorySize = 2**10;
    
    logic[31:0]instrMemory[0:instrMemorySize-1];
    int fd, fdReport;
    string filename = "example.s";
    string reportFilename = "report.txt";
    
    initial
    begin
        fdReport = $fopen(reportFilename, "w");
        fd = $fopen(filename, "r");
        $system("/opt/riscv/bin/riscv64-unknown-linux-gnu-as -march=rv32i -mabi=ilp32 example.s -o example.o");
        $system("/opt/riscv/bin/riscv64-unknown-linux-gnu-objcopy -O verilog --verilog-data-width=4 example.o example.bin");
        $readmemh("example.bin", instrMemory);
        
        for(int iIter = 0; iIter < instrMemorySize; iIter++)
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
                
                if(assemblyString == disassembledString)
                begin
                    $fdisplay(fdReport, "dissassembly matches");
                    $fdisplay(fdReport, "disassembledString: %s", disassembledString);
                    $fdisplay(fdReport, "assemblyString:     %s", assemblyString);
                end
                else
                begin
                    $fdisplay(fdReport, "instrMemory[iIter]: %h", instrMemory[iIter]);
                    $fdisplay(fdReport, "disassembledString: %s", disassembledString);
                    $fdisplay(fdReport, "assemblyString:     %s", assemblyString);
                end
            end
            else
                break;
        end
        $fclose(fd);
        $fclose(fdReport);
        $finish;
    end
endmodule