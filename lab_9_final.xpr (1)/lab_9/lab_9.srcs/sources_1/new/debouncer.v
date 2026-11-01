// debouncer.v
// Simple button debouncer for Basys 3 (reused from Lab 5)

module debouncer (
    input  clk,
    input  reset,
    input  btn_in,
    output reg btn_out
);

    reg [19:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count   <= 20'd0;
            btn_out <= 1'b0;
        end
        else begin
            if (btn_in == btn_out) begin
                count <= 20'd0;
            end
            else begin
                if (count == 20'd999999) begin
                    btn_out <= btn_in;
                    count   <= 20'd0;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

endmodule