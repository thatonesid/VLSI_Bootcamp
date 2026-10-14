`timescale 1ns / 1ps

module cic_tb();
    reg data [0:4096025];

    reg clk, reset;
    wire outready, outready2;

    reg  signed [1:0] bits;

    wire signed [19:0] cicout;
    wire signed [19:0] firout;

    initial begin
        $readmemh("hz10.mem", data);
    end

    initial begin
        clk = 0;
        bits = 0;
        reset = 1;
        #51 reset = 0;
    end
    always #50 clk = ~clk;

    integer i;
    initial i = 0;

    integer fd2, fd3, fd4;
    integer ncic;
    initial begin
        ncic = 0;
        fd2 = $fopen("cic512_10_eq.txt","w");
        fd3 = $fopen("fircomp_10_eq.txt","w");
        fd4 = $fopen("cic512_10_by4_eq.txt","w");
    end

    always @(posedge clk) begin
        if (i < 4096026) begin
            if (i%2==0) bits <= {1'b0, data[i]};
            else        bits <= {2{data[i]}};
            i <= i + 1;
        end else begin
            #5000;
            $fclose(fd2); $fclose(fd3); $fclose(fd4);
            $finish;
        end
    end

    always @(posedge clk) begin
        if (outready) begin
            $fwrite(fd2, "%0d\n", cicout);
            if (ncic % 4 == 0) $fwrite(fd4, "%0d\n", cicout);
            ncic <= ncic + 1;
        end
        if (outready2)
            $fwrite(fd3, "%0d\n", firout);
    end

    mycic #(.input_width(2), .R(512), .N(4), .output_width(20), .shift(16))
        cic (.clk(clk), .rst_n(~reset), .din(bits), .dout(cicout), .outready(outready));

    decim_top fir1 (.clk(clk), .rst_n(~reset), .din(bits),
                    .cic_dout(), .cic_ready(),
                    .dout(firout), .outready(outready2));
endmodule
