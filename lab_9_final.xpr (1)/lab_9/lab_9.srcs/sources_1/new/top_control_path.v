`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: top_control_path
// Lab 9 - Task 3: Control path on the FPGA
//
// Switches  -> instruction fields (opcode, funct3, funct7 bit 5)
// FSM       -> reads the switches, then updates the LEDs, over and over
// LEDs      -> control signals from MainControl and ALUControl
//
// Switch map:                      LED map:
//   SW[6:0]   opcode                 LD0   RegWrite
//   SW[9:7]   funct3                 LD1   ALUSrc
//   SW[10]    funct7 bit 5           LD2   MemRead
//                                    LD3   MemWrite
//                                    LD4   MemtoReg
//                                    LD5   Branch
//                                    LD7:6   ALUOp
//                                    LD11:8  ALUControl
//////////////////////////////////////////////////////////////////////////////////


module top_control_path (
    input  wire        clk,
    input  wire        pbin,            // reset button
    input  wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);


    // ============================================================
    // LAB 5 INTERFACE (reused: button debounce, switch read, LED write)
    // ============================================================

    wire        rst_clean;
    wire [31:0] switch_data;
    reg  [31:0] led_write_data;


    debouncer rst_db (
        .clk(clk),
        .reset(1'b0),
        .btn_in(pbin),
        .btn_out(rst_clean)
    );


    leds switch_reader (
        .clk(clk),
        .rst(1'b0),
        .btns(16'd0),
        .writeData(32'd0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(30'd0),
        .switches(physical_sw),
        .readData(switch_data)
    );


    switches led_writer (
        .clk(clk),
        .rst(1'b0),
        .writeData(led_write_data),
        .writeEnable(1'b1),
        .readEnable(1'b0),
        .memAddress(30'd0),
        .readData(),
        .leds(physical_leds)
    );


    // ============================================================
    // INSTRUCTION FIELDS (stored by the FSM)
    // ============================================================

    reg [6:0] opcode_reg;
    reg [2:0] funct3_reg;
    reg [6:0] funct7_reg;


    // ============================================================
    // CONTROL UNITS (from Task 2)
    // ============================================================

    wire       RegWrite;
    wire [1:0] ALUOp;
    wire       MemRead;
    wire       MemWrite;
    wire       ALUSrc;
    wire       MemtoReg;
    wire       Branch;
    wire [3:0] ALUControl;


    MainControl main_ctrl (
        .opcode(opcode_reg),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch)
    );


    ALUControl alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(funct3_reg),
        .funct7(funct7_reg),
        .ALUControl(ALUControl)
    );


    // ============================================================
    // FSM: two states, repeated forever
    //   S_READ : copy the switch positions into the field registers
    //   S_SHOW : copy the control signals into the LED register
    // ============================================================

    localparam S_READ = 1'b0;
    localparam S_SHOW = 1'b1;

    reg state;


    always @(posedge clk) begin

        if (rst_clean) begin
            // reset button: back to S_READ, clear everything, LEDs off
            state          <= S_READ;
            opcode_reg     <= 7'd0;
            funct3_reg     <= 3'd0;
            funct7_reg     <= 7'd0;
            led_write_data <= 32'd0;
        end

        else begin

            case (state)

                S_READ: begin
                    opcode_reg <= switch_data[6:0];
                    funct3_reg <= switch_data[9:7];

                    // only bit 5 of funct7 matters here (0 = ADD, 1 = SUB),
                    // so the other six funct7 bits are tied to 0
                    funct7_reg <= {1'b0, switch_data[10], 5'b00000};

                    state <= S_SHOW;
                end


                S_SHOW: begin
                    led_write_data <= {20'd0,
                                       ALUControl,   // LD11:8
                                       ALUOp,        // LD7:6
                                       Branch,       // LD5
                                       MemtoReg,     // LD4
                                       MemWrite,     // LD3
                                       MemRead,      // LD2
                                       ALUSrc,       // LD1
                                       RegWrite};    // LD0

                    state <= S_READ;
                end

            endcase

        end

    end

endmodule