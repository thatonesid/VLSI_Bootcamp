`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2026 10:06:50 PM
// Design Name: 
// Module Name: mydec
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


module mydec_counter
    #(parameter R = 512)
    (
        input wire clk,
        input wire rst_n,
        output reg send
    );
    
    localparam counter_width = $clog2(R);
    
    reg [counter_width-1:0] cnt;
    
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            send <= 1'b0;
            cnt <= 0;
        end
        
        else begin
            if(cnt < R-1) begin
                cnt <= cnt + 1'b1;
                send <= 1'b0;
            end 
            
            else begin
                cnt <= 0;
                send <= 1'b0;
            end
            
            if(cnt == R-2) begin
                send <= 1'b1;
            end
        end
        
    end
endmodule
