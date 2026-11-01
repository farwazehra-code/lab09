// ALUControl.v
// ALU control unit for a single-cycle RISC-V (RV32I) processor.
// Inputs:  ALUOp (from MainControl), funct3, funct7
// Output:  ALUControl (4 bits), same codes as the Lab 6 ALU.
`timescale 1ns / 1ps
module ALUControl (
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,

    output reg [3:0] ALUControl
);


    // ---- ALU codes (must match ALU.v from Lab 6) ----
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SLL = 4'b0100;
    localparam ALU_SRL = 4'b0101;
    localparam ALU_SUB = 4'b0110;


    always @(*) begin

        // Safe default: ADD (also covers all "don't care" cases)
        ALUControl = ALU_ADD;


        case (ALUOp)

            2'b00: begin
                // loads, stores, ADDI: always add
                ALUControl = ALU_ADD;
            end


            2'b01: begin
                // BEQ: subtract and look at the Zero flag
                ALUControl = ALU_SUB;
            end


            2'b10: begin
                // R-type: funct3 picks the operation
                case (funct3)

                    3'b000: begin
                        // ADD or SUB: funct7 bit 5 tells them apart
                        if (funct7[5] == 1'b1)
                            ALUControl = ALU_SUB;
                        else
                            ALUControl = ALU_ADD;
                    end

                    3'b001: ALUControl = ALU_SLL;
                    3'b100: ALUControl = ALU_XOR;
                    3'b101: ALUControl = ALU_SRL;
                    3'b110: ALUControl = ALU_OR;
                    3'b111: ALUControl = ALU_AND;

                    default: ALUControl = ALU_ADD;

                endcase
            end


            default: begin
                ALUControl = ALU_ADD;
            end

        endcase

    end

endmodule