// ALUControl_tb.v
// Testbench for ALUControl.v
// Applies ALUOp / funct3 / funct7 for every supported instruction.

`timescale 1ns / 1ps


module ALUControl_tb;

    reg  [1:0] ALUOp;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire [3:0] ALUControl;


    ALUControl uut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );


    task run_test;
        input [255:0] name;
        input [1:0]   aluop_in;
        input [2:0]   f3_in;
        input [6:0]   f7_in;
        input [3:0]   expected;
        begin
            ALUOp  = aluop_in;
            funct3 = f3_in;
            funct7 = f7_in;
            #10;

            if (ALUControl === expected)
                $display("PASS: %0s | ALUOp=%b f3=%b f7=%b -> ALUControl=%b", name, aluop_in, f3_in, f7_in, ALUControl);
            else
                $display("FAIL: %0s | ALUOp=%b f3=%b f7=%b -> ALUControl=%b (expected %b)", name, aluop_in, f3_in, f7_in, ALUControl, expected);
        end
    endtask


    initial begin

        $display("---- Starting ALUControl tests ----");


        // ALUOp = 00: always ADD, funct3/funct7 are ignored (try odd values to prove it)
        run_test("LW  (ALUOp 00 -> ADD)",  2'b00, 3'b010, 7'b0000000, 4'b0010);
        run_test("LH  (ALUOp 00 -> ADD)",  2'b00, 3'b001, 7'b0000000, 4'b0010);
        run_test("LB  (ALUOp 00 -> ADD)",  2'b00, 3'b000, 7'b0000000, 4'b0010);
        run_test("SW  (ALUOp 00 -> ADD)",  2'b00, 3'b010, 7'b0000000, 4'b0010);
        run_test("SH  (ALUOp 00 -> ADD)",  2'b00, 3'b001, 7'b0000000, 4'b0010);
        run_test("SB  (ALUOp 00 -> ADD)",  2'b00, 3'b000, 7'b0000000, 4'b0010);
        run_test("ADDI, funct7 bit set (ADD)", 2'b00, 3'b000, 7'b0100000, 4'b0010);


        // ALUOp = 01: BEQ, always SUB
        run_test("BEQ (ALUOp 01 -> SUB)",  2'b01, 3'b000, 7'b0000000, 4'b0110);


        // ALUOp = 10: R-type, decided by funct3 and funct7
        run_test("ADD", 2'b10, 3'b000, 7'b0000000, 4'b0010);
        run_test("SUB", 2'b10, 3'b000, 7'b0100000, 4'b0110);
        run_test("SLL", 2'b10, 3'b001, 7'b0000000, 4'b0100);
        run_test("XOR", 2'b10, 3'b100, 7'b0000000, 4'b0011);
        run_test("SRL", 2'b10, 3'b101, 7'b0000000, 4'b0101);
        run_test("OR",  2'b10, 3'b110, 7'b0000000, 4'b0001);
        run_test("AND", 2'b10, 3'b111, 7'b0000000, 4'b0000);


        $display("---- ALUControl tests complete ----");
        $finish;

    end

endmodule