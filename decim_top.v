`timescale 1ns / 1ps

module decim_top
    #(parameter input_width    = 2,
      parameter cic_width   = 24,      // interim word: keep 4 extra bits, round only once at the end
      parameter cic_shift  = 12,      // 38-bit CIC result >> 12 -> 24 bits
      parameter output_width   = 20)
    (
    input  wire clk,
    input  wire rst_n,
    input  wire signed [input_width-1:0] din,
    output wire signed [cic_width-1:0] cic_dout,
    output wire cic_ready,
    output wire signed [output_width-1:0] dout,
    output wire outready
    );

    mycic #(.input_width(input_width), .R(512), .N(4), .output_width(cic_width), .shift(cic_shift))
            u_cic (
                .clk(clk), 
                .rst_n(rst_n), 
                .din(din),
               .dout(cic_dout), 
               .outready(cic_ready)
            );
            

    fir_comp #(.input_width(cic_width), .coef_width(16), .num_tap(15), .D(4), .output_width(output_width), .shift(15 + (cic_width - output_width)))
        u_fir (
            .clk(clk), 
            .rst_n(rst_n), 
            .din(cic_dout), 
            .din_valid(cic_ready),
            .dout(dout), 
            .outready(outready)
        );
endmodule
