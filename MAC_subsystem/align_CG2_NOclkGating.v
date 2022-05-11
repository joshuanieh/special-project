module align_CG2_NOclkGating(
           input i_clk,
           input  [ 4-1:0] denorm_pp,
           input  [ 6-1:0] exp,
           input  [ 6-1:0] max_exp,
           input i_valid,
           output [15-1:0] align_pp,
           output o_valid,
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
wire eq0;
wire [14-1:0] mux01;
EQ6 eq_0(eq0, exp_diff, 6'd0, numbers[1]);
MX#(14) mux_01(mux01, {1'd0, denorm_pp_with_leading_one, 10'd0}, {denorm_pp_with_leading_one, 11'd0}, eq0, numbers[2]);

wire eq2, g2;
wire [14-1:0] mux23;
COM6 com_2(eq2, g2, exp_diff, 6'd2, numbers[3]);
MX#(14) mux_23(mux23, {3'd0, denorm_pp_with_leading_one,  8'd0}, {2'd0, denorm_pp_with_leading_one,  9'd0}, eq2, numbers[4]);

wire eq4, g4;
wire [14-1:0] mux45;
COM6 com_4(eq4, g4, exp_diff, 6'd4, numbers[5]);
MX#(14) mux_45(mux45, {5'd0, denorm_pp_with_leading_one,  6'd0}, {4'd0, denorm_pp_with_leading_one,  7'd0}, eq4, numbers[6]);

wire eq6, g6;
wire [14-1:0] mux67;
COM6 com_6(eq6, g6, exp_diff, 6'd6, numbers[7]);
MX#(14) mux_67(mux67, {7'd0, denorm_pp_with_leading_one,  4'd0}, {6'd0, denorm_pp_with_leading_one,  5'd0}, eq6, numbers[8]);

wire eq8, g8;
wire [14-1:0] mux89;
COM6 com_8(eq8, g8, exp_diff, 6'd8, numbers[9]);
MX#(14) mux_89(mux89, {9'd0, denorm_pp_with_leading_one,  2'd0}, {8'd0, denorm_pp_with_leading_one,  3'd0}, eq8, numbers[10]);

wire eq10, g10;
wire [14-1:0] mux1011;
COM6 com_10(eq10, g10, exp_diff, 6'd10, numbers[11]);
MX#(14) mux_1011(mux1011, {11'd0, denorm_pp_with_leading_one}, {10'd0, denorm_pp_with_leading_one,  1'd0}, eq10, numbers[12]);

reg ge12;
wire eq12, g12, ge12_wire;
COM6 com_12(eq12, g12, exp_diff, 6'd12, numbers[17]);
OR2 or8(ge12_wire, g12, eq12, numbers[24]);

reg ge4, ge8;
wire ge2, ge4_wire, ge6, ge8_wire, ge10;
OR2 or3(ge2, g2, eq2, numbers[19]);
OR2 or4(ge4_wire, g4, eq4, numbers[20]);
OR2 or5(ge6, g6, eq6, numbers[21]);
OR2 or6(ge8_wire, g8, eq8, numbers[22]);
OR2 or7(ge10, g10, eq10, numbers[23]);
//second stage
wire [14-1:0] mux0123_wire;
reg [14-1:0] mux0123;
MX#(14) mux_0123(mux0123_wire, mux01, mux23, ge2, numbers[13]);

wire [14-1:0] mux4567_wire;
reg [14-1:0] mux4567;
MX#(14) mux_4567(mux4567_wire, mux45, mux67, ge6, numbers[14]);

wire [14-1:0] mux891011_wire;
reg [14-1:0] mux891011;
MX#(14) mux_891011(mux891011_wire, mux89, mux1011, ge10, numbers[15]);

reg o_valid_half;
integer out_batch;
always @(posedge i_clk) begin
    ge4 = ge4_wire;
    ge8 = ge8_wire;
    ge12 = ge12_wire;
    mux0123 = mux0123_wire;
    mux4567 = mux4567_wire;
    mux891011 = mux891011_wire;
    o_valid_half = i_valid;
    if(i_valid) begin
        out_batch = $fopen("120_each_stage_output.txt", "a");
        $fwrite(out_batch, "\nStage 2-1\n");
        $fwrite(out_batch, "Stage 2-1: %06X\n", ge4);
        $fwrite(out_batch, "Stage 2-1: %06X\n", ge8);
        $fwrite(out_batch, "Stage 2-1: %06X\n", ge12);
        $fwrite(out_batch, "Stage 2-1: %06X\n", mux0123);
        $fwrite(out_batch, "Stage 2-1: %06X\n", mux4567);
        $fwrite(out_batch, "Stage 2-1: %06X\n", mux891011);
        $fclose(out_batch);
    end
end
assign o_valid = o_valid_half;
//third stage
wire [14-1:0] mux01234567;
MX#(14) mux_01234567(mux01234567, mux0123, mux4567, ge4, numbers[16]);

wire [14-1:0] mux89101112up;
MX#(14) mux_89101112up(mux89101112up, mux891011, 14'd0, ge12, numbers[28]);

//forth stage
MX#(14) mux_shifted_unsign_pp(shifted_unsign_pp, mux01234567, mux89101112up, ge8, numbers[18]);


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
    .number(numbers[25])
);

ADD#(15) add_100(
    .i_a(inv_tmp),
    .i_b(15'b1),
    .o_s(negative_num),
    .o_c(whatsoever),
    .number(numbers[26])
);

MX#(15) mux_align_pp(align_pp, {1'b0, shifted_unsign_pp}, negative_num, pp_sign, numbers[27]);

reg [50:0] sum;
integer j;
always @(*) begin
    sum = 0;
    for (j=0; j<29; j=j+1) begin 
        sum = sum + numbers[j];
    end
end

assign number = sum;
endmodule
