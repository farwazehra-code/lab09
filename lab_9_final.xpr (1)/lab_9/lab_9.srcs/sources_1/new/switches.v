`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: switches
// LED interface from Lab 5 (reused).
// Despite the name, this module WRITES the physical LEDs.
//////////////////////////////////////////////////////////////////////////////////


module switches(
    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    output reg [31:0] readData = 0,
    output reg [15:0] leds
);

    always @(posedge clk) begin
        if (rst)
            leds <= 16'd0;
        else if (writeEnable)
            leds <= writeData[15:0];
    end

endmodule