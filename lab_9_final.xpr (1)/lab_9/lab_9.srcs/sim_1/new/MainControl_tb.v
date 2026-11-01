// MainControl_tb.v
// Testbench for MainControl.v
// Applies the opcode of every supported instruction and checks all outputs.

`timescale 1ns / 1ps


module MainControl_tb;

    reg  [6:0] opcode;

    wire       RegWrite;
    wire [1:0] ALUOp;
    wire       MemRead;
    wire       MemWrite;
    wire       ALUSrc;
    wire       MemtoReg;
    wire       Branch;


    MainControl uut (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch)
    );


    // Packs the 7 outputs into one 8-bit value so they can be compared at once:
    // {RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp[1:0]}
    wire [7:0] actual;
    assign actual = {RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp};


    task run_test;
        input [255:0] name;
        input [6:0]   opcode_in;
        input [7:0]   expected;
        begin
            opcode = opcode_in;
            #10;

            if (actual === expected)
                $display("PASS: %0s | opcode=%b | outputs=%b", name, opcode_in, actual);
            else
                $display("FAIL: %0s | opcode=%b | outputs=%b (expected %b)", name, opcode_in, actual, expected);
        end
    endtask


    initial begin

        $display("---- Starting MainControl tests ----");
        $display("Output order: RegWrite ALUSrc MemRead MemWrite MemtoReg Branch ALUOp");


        // R-type: RegWrite=1 ALUSrc=0 MemRead=0 MemWrite=0 MemtoReg=0 Branch=0 ALUOp=10
        run_test("ADD",  7'b0110011, 8'b1_0_0_0_0_0_10);
        run_test("SUB",  7'b0110011, 8'b1_0_0_0_0_0_10);
        run_test("SLL",  7'b0110011, 8'b1_0_0_0_0_0_10);
        run_test("SRL",  7'b0110011, 8'b1_0_0_0_0_0_10);
        run_test("AND",  7'b0110011, 8'b1_0_0_0_0_0_10);
        run_test("OR",   7'b0110011, 8'b1_0_0_0_0_0_10);
        run_test("XOR",  7'b0110011, 8'b1_0_0_0_0_0_10);


        // ADDI: RegWrite=1 ALUSrc=1 MemRead=0 MemWrite=0 MemtoReg=0 Branch=0 ALUOp=00
        run_test("ADDI", 7'b0010011, 8'b1_1_0_0_0_0_00);


        // Loads: RegWrite=1 ALUSrc=1 MemRead=1 MemWrite=0 MemtoReg=1 Branch=0 ALUOp=00
        run_test("LW",   7'b0000011, 8'b1_1_1_0_1_0_00);
        run_test("LH",   7'b0000011, 8'b1_1_1_0_1_0_00);
        run_test("LB",   7'b0000011, 8'b1_1_1_0_1_0_00);


        // Stores: RegWrite=0 ALUSrc=1 MemRead=0 MemWrite=1 MemtoReg=X(0) Branch=0 ALUOp=00
        run_test("SW",   7'b0100011, 8'b0_1_0_1_0_0_00);
        run_test("SH",   7'b0100011, 8'b0_1_0_1_0_0_00);
        run_test("SB",   7'b0100011, 8'b0_1_0_1_0_0_00);


        // BEQ: RegWrite=0 ALUSrc=0 MemRead=0 MemWrite=0 MemtoReg=X(0) Branch=1 ALUOp=01
        run_test("BEQ",  7'b1100011, 8'b0_0_0_0_0_1_01);


        // Unknown opcode: everything must stay at the safe default (all zero)
        run_test("UNKNOWN opcode (safe default)", 7'b1111111, 8'b0_0_0_0_0_0_00);


        $display("---- MainControl tests complete ----");
        $finish;

    end

endmodule