`timescale 1ns/1ps

module tb_div3();

    localparam  CLK_PERIOD=10;
    reg         ref_clk;
    reg         rstn;
    wire        clk_out;
    initial begin
        ref_clk <=  1'b0;
        rstn    <=  1'b0;
        repeat(10) @(posedge ref_clk);
        rstn    <=  1'b1;
    end

    always begin
        #(CLK_PERIOD/2)
        ref_clk <=  ~ref_clk;
    end

    div3 inst_div3(
        .i_clk_in   (ref_clk),
        .i_rstn     (rstn),
        .o_clk_out  (clk_out)
    );

endmodule