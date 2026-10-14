`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2026 10:04:47 PM
// Design Name: 
// Module Name: mycomb
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


module mycomb
    #(parameter acc_width = 38)
    (
        input wire clk,
        input wire rst_n,
        input wire signed [acc_width-1:0] din,
        input wire send,
        output reg signed [acc_width-1:0] dout
    );
    
    reg signed [acc_width-1:0] prev;
    
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            prev <= {acc_width{1'b0}};
            dout <= {acc_width{1'b0}};
        end
        
        else begin
            if(send) begin
                prev <= din;
                dout <= din - prev;
            end 
        end
    end 
    
    
    
endmodule
