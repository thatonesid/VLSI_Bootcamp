`timescale 1ns / 1ps

module fir_comp
    #(parameter input_width = 24,
      parameter coef_width = 16,
      parameter num_tap = 15,
      parameter D = 4,
      parameter output_width = 20,
      parameter shift  = 19)
    (
    input  wire clk,
    input  wire rst_n,
    input  wire signed [input_width-1:0] din,
    input  wire din_valid, 
    output reg  signed [output_width-1:0] dout,
    output reg outready
    );

    localparam accumulator_width = input_width + coef_width + $clog2(num_tap);
    localparam kw    = $clog2(num_tap);
    localparam pw    = (D > 1) ? $clog2(D) : 1;

    function signed [coef_width-1:0] coef;
        input [kw-1:0] k;
        begin
            case (k)
                4'd0,  4'd14: coef =   1005;
                4'd1,  4'd13: coef =    968;
                4'd2,  4'd12: coef =  -1136;
                4'd3,  4'd11: coef =  -3847;
                4'd4,  4'd10: coef =  -2533;
                4'd5,  4'd9 : coef =   5515;
                4'd6,  4'd8 : coef =  16245;
                4'd7        : coef =  21274;
                default     : coef =     0;
            endcase
        end
    endfunction

    reg signed [input_width-1:0] x [0:num_tap-1];
    reg [pw-1:0] ph;
    reg busy;
    reg [kw-1:0] k;
    reg done; 
    reg signed [accumulator_width-1:0] acc;

    localparam top = shift + output_width - 1;
    localparam signed [accumulator_width-1:0] half = (1 <<< (shift-1));
    wire signed [accumulator_width-1:0]  rnd = acc + half;
    wire [accumulator_width-1-top:0] top_bits = rnd[accumulator_width-1:top];
    wire fits = (&top_bits) | ~(|top_bits);
    wire signed [output_width-1:0]  sat_val  = rnd[accumulator_width-1] ? {1'b1, {(output_width-1){1'b0}}} : {1'b0, {(output_width-1){1'b1}}};

    integer j;
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
        
            for (j = 0; j < num_tap; j = j + 1) 
                x[j] <= 0;
            ph <= 0; 
            busy <= 1'b0; 
            k <= 0; 
            done <= 1'b0;
            acc <= 0; 
            dout <= 0; 
            outready <= 1'b0;
            
        end 
        
        else begin
            outready <= 1'b0; 

            if (din_valid) begin
            
                for (j = num_tap-1; j > 0; j = j - 1)
                    x[j] <= x[j-1];
                    
                x[0] <= din;
                
                if (ph == D-1) begin
                    ph   <= 0;
                    busy <= 1'b1;
                    k    <= 0;
                    acc  <= 0;
                end
                
                else
                    ph <= ph + 1'b1;
                    
            end

            else 
                if (busy) begin
                    acc <= acc + x[k] * coef(k);
                    if (k == num_tap-1) begin
                        busy <= 1'b0;
                        done <= 1'b1;
                end
                k <= k + 1'b1;
            end

            if (done) begin
                done     <= 1'b0;
                dout     <= fits ? rnd[top:shift] : sat_val;
                outready <= 1'b1;
            end
        end
    end
endmodule
