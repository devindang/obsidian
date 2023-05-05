// div_5

`timescale 1ns/1ps
module div3 (
    input   i_clk_in,
    input   i_rstn,
    output  o_clk_out
);
    reg [2:0]   count1;
    reg [2:0]   count2;
    reg         div_clk1;
    reg         div_clk2;

    always@(posedge i_clk_in or negedge i_rstn) begin
        if(~i_rstn) begin
            count1      <=  'd0;
            div_clk1    <=  'b0;
        end
        else begin
            if(count1==4) begin
                count1   <=  'd0;
            end
            else begin
                count1   <=  count1 + 1;
            end
            if(count1==1 || count1==2) begin
                div_clk1    <=  1'b1;
            end
            else begin
                div_clk1    <=  1'b0;
            end
        end
    end

    always@(negedge i_clk_in) begin
        if(~i_rstn) begin
            count2      <=  'd0;
            div_clk2    <=  'b0;
        end
        else begin
            if(count2==4) begin
                count2   <=  'd0;
            end
            else begin
                count2   <=  count2 + 1;
            end
            if(count2==1 || count2==2) begin
                div_clk2    <=  1'b1;
            end
            else begin
                div_clk2    <=  1'b0;
            end
        end
    end

assign o_clk_out = div_clk1 || div_clk2;

endmodule