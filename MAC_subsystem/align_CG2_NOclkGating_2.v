module align_CG2_NOclkGating_2(
           input  [14-1:0] i_shifted_unsign_pp,
           input           i_pp_sign,
           output [15-1:0] align_pp,
           output [50:0]   number
       );

wire [50:0] numbers[28:0];

/* ----------------------------- Sign Extension ----------------------------- */
// align_pp
//                    exp_diff = 11    ----->           |  2 | 1 | 0 |
//                                                      | ld .       |
// | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 |  2 | 1 | 0 |
// |  S |    .                                        G    R   S     |
// assign align_pp = (pp_sign) ? ~{1'b0, shifted_unsign_pp} + 1'b1 : {1'b0, shifted_unsign_pp};
wire [15-1:0] inv_tmp, negative_num;
wire whatsoever;
INV#(15) inv_100(
    .i_a({1'b0, i_shifted_unsign_pp}),
    .o_z(inv_tmp),
    .number(numbers[0])
);

ADD#(15) add_100(
    .i_a(inv_tmp),
    .i_b(15'b1),
    .o_s(negative_num),
    .o_c(whatsoever),
    .number(numbers[1])
);

MX#(15) mux_align_pp(align_pp, {1'b0, i_shifted_unsign_pp}, negative_num, i_pp_sign, numbers[2]);

reg [50:0] sum;
integer j;
always @(*) begin
    sum = 0;
    for (j=0; j<3; j=j+1) begin 
        sum = sum + numbers[j];
    end
end

assign number = sum;
endmodule
