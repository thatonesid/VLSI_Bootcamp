`timescale 1ns / 1ps

module mycic
    #(parameter input_width = 2, parameter R = 512, parameter N = 4, parameter output_width = 20, parameter shift = 16)
    (
    input  wire clk,
    input  wire rst_n,
    input  wire signed [input_width-1:0]  din,
    output reg  signed [output_width-1:0] dout,
    output reg  outready
    );

    localparam acc_width = input_width + N*$clog2(R);

    wire signed [acc_width-1:0] w [N:0];
    assign w[0] = din;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : iut
            myint #(.input_width(acc_width), .acc_width(acc_width))
                  u_int (.clk(clk), .rst_n(rst_n), .din(w[i]), .dout(w[i+1]));
        end
    endgenerate

    wire send;
    mydec_counter #(.R(R)) u_dec (.clk(clk), .rst_n(rst_n), .send(send));

    wire signed [acc_width-1:0] c [N:0];
    assign c[0] = w[N];
    generate
        for (i = 0; i < N; i = i + 1) begin : cut
            mycomb #(.acc_width(acc_width))
                   u_comb (.clk(clk), .rst_n(rst_n), .din(c[i]), .send(send), .dout(c[i+1]));
        end
    endgenerate

    localparam top = shift + output_width - 1;
    localparam signed [acc_width-1:0] HALF = (1 <<< (shift-1));

    wire signed [acc_width-1:0]     rnd      = c[N] + HALF;
    wire [acc_width-1-top:0]        top_bits = rnd[acc_width-1:top];
    wire                            fits     = (&top_bits) | ~(|top_bits);
    wire signed [output_width-1:0]  sat_val  = rnd[acc_width-1] ? {1'b1, {(output_width-1){1'b0}}} : {1'b0, {(output_width-1){1'b1}}};

    reg send_d;
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            send_d   <= 1'b0;
            outready <= 1'b0;
            dout     <= 0;
        end else begin
            send_d   <= send;
            outready <= send_d;
            dout     <= fits ? rnd[top:shift] : sat_val;
        end
    end
endmodule
