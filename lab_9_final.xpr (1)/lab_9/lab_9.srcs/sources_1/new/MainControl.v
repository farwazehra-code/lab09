// MainControl.v
// Main control unit for a single-cycle RISC-V (RV32I) processor.
// Input:  opcode (7 bits)
// Output: control signals, taken straight from the Task 1 truth table.

`timescale 1ns / 1ps
module MainControl (
    input  [6:0] opcode,

    output reg       RegWrite,
    output reg [1:0] ALUOp,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg       Branch
);


    // ---- opcodes ----
    localparam OP_RTYPE  = 7'b0110011;   // ADD, SUB, SLL, SRL, AND, OR, XOR
    localparam OP_ITYPE  = 7'b0010011;   // ADDI
    localparam OP_LOAD   = 7'b0000011;   // LW, LH, LB
    localparam OP_STORE  = 7'b0100011;   // SW, SH, SB
    localparam OP_BRANCH = 7'b1100011;   // BEQ


    always @(*) begin

        // Safe defaults first: do nothing at all.
        // Any "don't care" (X) in the truth table ends up as 0 here.
        RegWrite = 1'b0;
        ALUOp    = 2'b00;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;


        case (opcode)

            OP_RTYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10;
            end


            OP_ITYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
            end


            OP_LOAD: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUOp    = 2'b00;
            end


            OP_STORE: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end


            OP_BRANCH: begin
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end


            default: begin
                // unknown opcode: all outputs stay at the defaults above (all zero)
            end

        endcase

    end

endmodule