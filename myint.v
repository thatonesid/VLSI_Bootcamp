`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2026 10:06:31 PM
// Design Name: 
// Module Name: myint
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module myint
    #(parameter input_width = 2, acc_width = 38)
    (
        input wire clk,
        input wire rst_n, 
        input wire signed [input_width-1:0] din,
        output reg signed [acc_width-1:0] dout
    );
    
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            dout <= {acc_width{1'b0}};
        end
        
        else begin
            dout <= dout + din;
        end
        
    end
    
    
endmodule
