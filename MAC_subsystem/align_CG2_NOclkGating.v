module align_CG2_NOclkGating(
           input  [ 4-1:0] denorm_pp,
           input  [ 6-1:0] exp,
           input  [ 6-1:0] max_exp,
           output [15-1:0] align_pp,
           output [50:0]   number
       );

wire [50:0] numbers[28:0];

// Exponential Difference
// partial products will be aligned to the max_exp
// wire [6-1:0] exp_diff = max_exp - exp;
wire [6-1:0] exp_diff;
wire whatever;
SUB#(6) sub1(
    .i_a(max_exp),
    .i_b(exp),
    .o_d(exp_diff),
    .o_b(whatever),
    .number(numbers[0])
);


// denorm_pp
// | 3 |  2 | 1 | 0 |
// | S | ld .       |
wire pp_sign = denorm_pp[3];


// denorm_pp_with_leading_one
// |  2 | 1 | 0 |
// | ld .       |
wire [3-1:0] denorm_pp_with_leading_one = denorm_pp[2:0];


// shifted_unsign_pp
//               exp_diff = 11    ----->           |  2 | 1 | 0 |
//                                                 | ld .       |
// | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 |  2 | 1 | 0 |
// |    .                                        G    R   S     |
// reg [14-1:0] shifted_unsign_pp;
// always@(*) begin
//     case(exp_diff)
//         6'd0 : shifted_unsign_pp = {       denorm_pp_with_leading_one, 11'd0}; // shifted_unsign_pp1 has one more bit for the signed bit.
//         6'd1 : shifted_unsign_pp = { 1'd0, denorm_pp_with_leading_one, 10'd0}; // discard the LSB.
//         6'd2 : shifted_unsign_pp = { 2'd0, denorm_pp_with_leading_one,  9'd0}; // discard the LSB.
//         6'd3 : shifted_unsign_pp = { 3'd0, denorm_pp_with_leading_one,  8'd0}; // discard the LSB.
//         6'd4 : shifted_unsign_pp = { 4'd0, denorm_pp_with_leading_one,  7'd0}; // discard the LSB.
//         6'd5 : shifted_unsign_pp = { 5'd0, denorm_pp_with_leading_one,  6'd0}; // discard the LSB.
//         6'd6 : shifted_unsign_pp = { 6'd0, denorm_pp_with_leading_one,  5'd0}; // discard the LSB.
//         6'd7 : shifted_unsign_pp = { 7'd0, denorm_pp_with_leading_one,  4'd0}; // discard the LSB.
//         6'd8 : shifted_unsign_pp = { 8'd0, denorm_pp_with_leading_one,  3'd0}; // discard the LSB.
//         6'd9 : shifted_unsign_pp = { 9'd0, denorm_pp_with_leading_one,  2'd0}; // discard the LSB.
//         6'd10: shifted_unsign_pp = {10'd0, denorm_pp_with_leading_one,  1'd0}; // discard the LSB.
//         6'd11: shifted_unsign_pp = {11'd0, denorm_pp_with_leading_one       }; // discard the LSB.
//         default: shifted_unsign_pp = 14'd0;
//     endcase
// end
wire [14-1:0] shifted_unsign_pp;
//first stage
wire g11, a, g7;
AN2 an2(a, exp_diff[2], exp_diff[3], numbers[1]);
OR3 or3(g11, a, exp_diff[4], exp_diff[5], numbers[17]);
OR3 or31(g7, exp_diff[3], exp_diff[4], exp_diff[5], numbers[18]);

wire [14-1:0] mux01;
wire [14-1:0] mux23;
wire [14-1:0] mux45;
wire [14-1:0] mux67;
wire [14-1:0] mux89;
wire [14-1:0] mux1011;

MX#(14) mux_01(mux01, {denorm_pp_with_leading_one, 11'd0}, {1'd0, denorm_pp_with_leading_one, 10'd0}, exp_diff[0], numbers[2]);
MX#(14) mux_23(mux23, {2'd0, denorm_pp_with_leading_one,  9'd0}, {3'd0, denorm_pp_with_leading_one,  8'd0}, exp_diff[0], numbers[3]);
MX#(14) mux_45(mux45, {4'd0, denorm_pp_with_leading_one,  7'd0}, {5'd0, denorm_pp_with_leading_one,  6'd0}, exp_diff[0], numbers[4]);
MX#(14) mux_67(mux67, {6'd0, denorm_pp_with_leading_one,  5'd0}, {7'd0, denorm_pp_with_leading_one,  4'd0}, exp_diff[0], numbers[5]);
MX#(14) mux_89(mux89, {8'd0, denorm_pp_with_leading_one,  3'd0}, {9'd0, denorm_pp_with_leading_one,  2'd0}, exp_diff[0], numbers[6]);
MX#(14) mux_1011(mux1011, {10'd0, denorm_pp_with_leading_one,  1'd0}, {11'd0, denorm_pp_with_leading_one}, exp_diff[0], numbers[7]);

//second stage
wire [14-1:0] mux0123;
wire [14-1:0] mux4567;
wire [14-1:0] mux891011;

MX#(14) mux_0123(mux0123, mux01, mux23, exp_diff[1], numbers[8]);
MX#(14) mux_4567(mux4567, mux45, mux67, exp_diff[1], numbers[9]);
MX#(14) mux_891011(mux891011, mux89, mux1011, exp_diff[1], numbers[10]);

//third stage
wire [14-1:0] mux01234567;
wire [14-1:0] mux89101112up;

MX#(14) mux_01234567(mux01234567, mux0123, mux4567, exp_diff[2], numbers[11]);
MX#(14) mux_89101112up(mux89101112up, mux891011, 14'd0, g11, numbers[12]);

//forth stage
MX#(14) mux_shifted_unsign_pp(shifted_unsign_pp, mux01234567, mux89101112up, g7, numbers[13]);

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
    .i_a({1'b0, shifted_unsign_pp}),
    .o_z(inv_tmp),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp),
    .i_b(15'b1),
    .o_s(negative_num),
    .o_c(whatsoever),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp, {1'b0, shifted_unsign_pp}, negative_num, pp_sign, numbers[16]);

reg [50:0] sum;
integer j;
always @(*) begin
    sum = 0;
    for (j=0; j<19; j=j+1) begin 
        sum = sum + numbers[j];
    end
end

assign number = sum;
endmodule
