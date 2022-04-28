module final_norm_noSUB(
           input  [19-1:0] sum,
           output [11-1:0] final_norm_sum_with_leading1,
           output signed [5-1:0] signed_exp_diff,
           output exp_carry,
           output sign,
           output [50:0] number
       );

wire [50:0] numbers[100:0];
// unsign_sum
//                    exp_diff = 11    ----->                               |  2 | 1 | 0 |
//                                                                          | ld .       |
//      |<--                       leading_vector                       --> |
// | 18 | 17 | 16 | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 |  2 | 1 | 0 |
// |  0 |                        .                                        G |  R   S     |
assign sign = sum[18];
// wire [19-1:0] unsign_sum = (sign) ? ~sum + 1'b1 : sum;
wire [19-1:0] unsign_sum, inverted_sum, negative_sum_magnitude;
wire whatsoever;
INV#(19) inv_100(
    .i_a(sum),
    .o_z(inverted_sum),
    .number(numbers[20])
);

ADD#(19) add_100(
    .i_a(inverted_sum),
    .i_b(19'b1),
    .o_s(negative_sum_magnitude),
    .o_c(whatsoever),
    .number(numbers[21])
);
MX#(19) g_1(unsign_sum, sum, negative_sum_magnitude, sign, numbers[0]);


/* --------------------- Normalized Sum with Leading One -------------------- */
wire [15-1:0] leading_vector;
wire first_four_bits_or;
OR4 g_2(first_four_bits_or, unsign_sum[17], unsign_sum[16], unsign_sum[15], unsign_sum[14], numbers[1]);
wire first_seven_bits_or;
OR4 g_3(first_seven_bits_or, unsign_sum[13], unsign_sum[12], unsign_sum[11], first_four_bits_or, numbers[2]);
wire third_ten_bits_or;
OR4 g_4(first_ten_bits_or, unsign_sum[10], unsign_sum[9], unsign_sum[8], first_seven_bits_or, numbers[3]);
wire third_thirteen_bits_or;
OR4 g_18(first_thirteen_bits_or, unsign_sum[7], unsign_sum[6], unsign_sum[5], first_ten_bits_or, numbers[17]);

wire [16:3] inverted_unsigned_sum;
INV#(14) g_5(unsign_sum[16:3], inverted_unsigned_sum, numbers[4]);

assign leading_vector[14] = unsign_sum[17];

// assign leading_vector[13] = ( (|unsign_sum[17]    == 0) && (unsign_sum[16] == 1'b1) ) ? 1'b1 : 0;
NR2 g_6(leading_vector[13], unsign_sum[17], inverted_unsigned_sum[16], numbers[5]);

// assign leading_vector[12] = ( (|unsign_sum[17:16] == 0) && (unsign_sum[15] == 1'b1) ) ? 1'b1 : 0;
NR3 g_7(leading_vector[12], unsign_sum[17], unsign_sum[16], inverted_unsigned_sum[15], numbers[6]);

// assign leading_vector[11] = ( (|unsign_sum[17:15] == 0) && (unsign_sum[14] == 1'b1) ) ? 1'b1 : 0;
NR4 g_8(leading_vector[11], unsign_sum[17], unsign_sum[16], unsign_sum[15], inverted_unsigned_sum[14], numbers[7]);

// assign leading_vector[10] = ( (|unsign_sum[17:14] == 0) && (unsign_sum[13] == 1'b1) ) ? 1'b1 : 0;
NR2 g_9(leading_vector[10], first_four_bits_or, inverted_unsigned_sum[13], numbers[8]);

// assign leading_vector[ 9] = ( (|unsign_sum[17:13] == 0) && (unsign_sum[12] == 1'b1) ) ? 1'b1 : 0;
NR3 g_10(leading_vector[9], first_four_bits_or, unsign_sum[13], inverted_unsigned_sum[12], numbers[9]);

// assign leading_vector[ 8] = ( (|unsign_sum[17:12] == 0) && (unsign_sum[11] == 1'b1) ) ? 1'b1 : 0;
NR4 g_11(leading_vector[8], first_four_bits_or, unsign_sum[13], unsign_sum[12], inverted_unsigned_sum[11], numbers[10]);

// assign leading_vector[ 7] = ( (|unsign_sum[17:11] == 0) && (unsign_sum[10] == 1'b1) ) ? 1'b1 : 0;
NR2 g_12(leading_vector[7], first_seven_bits_or, inverted_unsigned_sum[10], numbers[11]);

// assign leading_vector[ 6] = ( (|unsign_sum[17:10] == 0) && (unsign_sum[ 9] == 1'b1) ) ? 1'b1 : 0;
NR3 g_13(leading_vector[6], first_seven_bits_or, unsign_sum[10], inverted_unsigned_sum[9], numbers[12]);

// assign leading_vector[ 5] = ( (|unsign_sum[17: 9] == 0) && (unsign_sum[ 8] == 1'b1) ) ? 1'b1 : 0;
NR4 g_14(leading_vector[5], first_seven_bits_or, unsign_sum[10], unsign_sum[9], inverted_unsigned_sum[8], numbers[13]);

// assign leading_vector[ 4] = ( (|unsign_sum[17: 8] == 0) && (unsign_sum[ 7] == 1'b1) ) ? 1'b1 : 0;
NR2 g_15(leading_vector[4], first_ten_bits_or, inverted_unsigned_sum[7], numbers[14]);

// assign leading_vector[ 3] = ( (|unsign_sum[17: 7] == 0) && (unsign_sum[ 6] == 1'b1) ) ? 1'b1 : 0;
NR3 g_16(leading_vector[3], first_ten_bits_or, unsign_sum[7], inverted_unsigned_sum[6], numbers[15]);

// assign leading_vector[ 2] = ( (|unsign_sum[17: 6] == 0) && (unsign_sum[ 5] == 1'b1) ) ? 1'b1 : 0;
NR4 g_17(leading_vector[2], first_ten_bits_or, unsign_sum[7], unsign_sum[6], inverted_unsigned_sum[5], numbers[16]);

// assign leading_vector[ 1] = ( (|unsign_sum[17: 5] == 0) && (unsign_sum[ 4] == 1'b1) ) ? 1'b1 : 0;
NR2 g_19(leading_vector[1], first_thirteen_bits_or, inverted_unsigned_sum[4], numbers[18]);

// assign leading_vector[ 0] = ( (|unsign_sum[17: 4] == 0) && (unsign_sum[ 3] == 1'b1) ) ? 1'b1 : 0;
NR3 g_20(leading_vector[0], first_thirteen_bits_or, unsign_sum[4], inverted_unsigned_sum[3], numbers[19]);
// norm_sum_with_leading1
// | 10 |  9 |  8 |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
// |    .                                            | GB |
// reg [11-1:0] norm_sum_with_leading1;
// always @(*) begin
//     case (leading_vector)
//         15'b10000_00000_00000: norm_sum_with_leading1 = unsign_sum[17: 7]; // Decimal point shift 4-bit left  (<-)
//         15'b01000_00000_00000: norm_sum_with_leading1 = unsign_sum[16: 6]; // Decimal point shift 3-bit left  (<-)
//         15'b00100_00000_00000: norm_sum_with_leading1 = unsign_sum[15: 5]; // Decimal point shift 2-bit left  (<-)
//         15'b00010_00000_00000: norm_sum_with_leading1 = unsign_sum[14: 4]; // Decimal point shift 1-bit left  (<-)
//         15'b00001_00000_00000: norm_sum_with_leading1 = unsign_sum[13: 3]; // No shift
//         15'b00000_10000_00000: norm_sum_with_leading1 = unsign_sum[12: 2]; // Decimal point shift 1-bit right (->)
//         15'b00000_01000_00000: norm_sum_with_leading1 = unsign_sum[11: 1]; // Decimal point shift 2-bit right (->)
//         15'b00000_00100_00000: norm_sum_with_leading1 = unsign_sum[10: 0]; // Decimal point shift 3-bit right (->)

//         15'b00000_00010_00000: norm_sum_with_leading1 = {unsign_sum[ 9: 0], 1'd0}; // Decimal point shift 4-bit right (->)
//         15'b00000_00001_00000: norm_sum_with_leading1 = {unsign_sum[ 8: 0], 2'd0}; // Decimal point shift 5-bit right (->)
//         15'b00000_00000_10000: norm_sum_with_leading1 = {unsign_sum[ 7: 0], 3'd0}; // Decimal point shift 6-bit right (->)
//         15'b00000_00000_01000: norm_sum_with_leading1 = {unsign_sum[ 6: 0], 4'd0}; // Decimal point shift 7-bit right (->)
//         15'b00000_00000_00100: norm_sum_with_leading1 = {unsign_sum[ 5: 0], 5'd0}; // Decimal point shift 8-bit right (->)
//         15'b00000_00000_00010: norm_sum_with_leading1 = {unsign_sum[ 4: 0], 6'd0}; // Decimal point shift 9-bit right (->)
//         15'b00000_00000_00001: norm_sum_with_leading1 = {unsign_sum[ 3: 0], 7'd0}; // Decimal point shift 10-bit right
//         default: norm_sum_with_leading1 = 11'd0;
//     endcase
// end
wire [11-1:0] norm_sum_with_leading1;
wire [15-1:0] norm_sum_with_leading1_array[11-1:0];
AND#(15) g1001(norm_sum_with_leading1_array[10], unsign_sum[17:3], leading_vector, numbers[43]);
AND#(15) g1002(norm_sum_with_leading1_array[9], unsign_sum[16:2], leading_vector, numbers[42]);
AND#(15) g1003(norm_sum_with_leading1_array[8], unsign_sum[15:1], leading_vector, numbers[22]);
AND#(15) g1004(norm_sum_with_leading1_array[7], unsign_sum[14:0], leading_vector, numbers[23]);
AND#(15) g1005(norm_sum_with_leading1_array[6], {unsign_sum[13:0], 1'd0}, leading_vector, numbers[24]);
AND#(15) g1006(norm_sum_with_leading1_array[5], {unsign_sum[12:0], 2'd0}, leading_vector, numbers[25]);
AND#(15) g1007(norm_sum_with_leading1_array[4], {unsign_sum[11:0], 3'd0}, leading_vector, numbers[26]);
AND#(15) g1008(norm_sum_with_leading1_array[3], {unsign_sum[10:0], 4'd0}, leading_vector, numbers[27]);
AND#(15) g1009(norm_sum_with_leading1_array[2], {unsign_sum[9:0], 5'd0}, leading_vector, numbers[28]);
AND#(15) g1010(norm_sum_with_leading1_array[1], {unsign_sum[8:0], 6'd0}, leading_vector, numbers[29]);
AND#(15) g1011(norm_sum_with_leading1_array[0], {unsign_sum[7:0], 7'd0}, leading_vector, numbers[30]);

OR#(15)  g2001(norm_sum_with_leading1[10], norm_sum_with_leading1_array[10], numbers[31]);
OR#(15)  g2002(norm_sum_with_leading1[9], norm_sum_with_leading1_array[9], numbers[32]);
OR#(15)  g2003(norm_sum_with_leading1[8], norm_sum_with_leading1_array[8], numbers[33]);
OR#(15)  g2004(norm_sum_with_leading1[7], norm_sum_with_leading1_array[7], numbers[34]);
OR#(15)  g2005(norm_sum_with_leading1[6], norm_sum_with_leading1_array[6], numbers[35]);
OR#(15)  g2006(norm_sum_with_leading1[5], norm_sum_with_leading1_array[5], numbers[36]);
OR#(15)  g2007(norm_sum_with_leading1[4], norm_sum_with_leading1_array[4], numbers[37]);
OR#(15)  g2008(norm_sum_with_leading1[3], norm_sum_with_leading1_array[3], numbers[38]);
OR#(15)  g2009(norm_sum_with_leading1[2], norm_sum_with_leading1_array[2], numbers[39]);
OR#(15)  g209(norm_sum_with_leading1[1], norm_sum_with_leading1_array[1], numbers[40]);
OR#(15)  g2011(norm_sum_with_leading1[0], norm_sum_with_leading1_array[0], numbers[41]);
// Change exp according to decimal point shift
// reg signed [5-1:0] signed_exp_diff;
// always @(*) begin
//     case (leading_vector)
//         15'b10000_00000_00000: signed_exp_diff =  5'sd4 ; // Decimal point shift 4-bit left (<-)
//         15'b01000_00000_00000: signed_exp_diff =  5'sd3 ; // Decimal point shift 3-bit left (<-)
//         15'b00100_00000_00000: signed_exp_diff =  5'sd2 ; // Decimal point shift 2-bit left (<-)
//         15'b00010_00000_00000: signed_exp_diff =  5'sd1 ; // Decimal point shift 1-bit left (<-)
//         15'b00001_00000_00000: signed_exp_diff =  5'sd0 ; // No shift
//         15'b00000_10000_00000: signed_exp_diff = -5'sd1 ; // Decimal point shift 1-bit right (->)
//         15'b00000_01000_00000: signed_exp_diff = -5'sd2 ; // Decimal point shift 2-bit right (->)
//         15'b00000_00100_00000: signed_exp_diff = -5'sd3 ; // Decimal point shift 3-bit right (->)
//         15'b00000_00010_00000: signed_exp_diff = -5'sd4 ; // Decimal point shift 4-bit right (->)
//         15'b00000_00001_00000: signed_exp_diff = -5'sd5 ; // Decimal point shift 5-bit right (->)
//         15'b00000_00000_10000: signed_exp_diff = -5'sd6 ; // Decimal point shift 6-bit right (->)
//         15'b00000_00000_01000: signed_exp_diff = -5'sd7 ; // Decimal point shift 7-bit right (->)
//         15'b00000_00000_00100: signed_exp_diff = -5'sd8 ; // Decimal point shift 8-bit right (->)
//         15'b00000_00000_00010: signed_exp_diff = -5'sd9 ; // Decimal point shift 9-bit right (->)
//         15'b00000_00000_00001: signed_exp_diff = -5'sd10; // Decimal point shift 10-bit right (->)
//         default: signed_exp_diff = 5'sd0;
//     endcase
// end
wire signed [5-1:0] exp[15];
assign exp[14] = 5'sd4;
assign exp[13] = 5'sd3;
assign exp[12] = 5'sd2;
assign exp[11] = 5'sd1;
assign exp[10] = 5'sd0;
assign exp[9] = -5'sd1;
assign exp[8] = -5'sd2;
assign exp[7] = -5'sd3;
assign exp[6] = -5'sd4;
assign exp[5] = -5'sd5;
assign exp[4] = -5'sd6;
assign exp[3] = -5'sd7;
assign exp[2] = -5'sd8;
assign exp[1] = -5'sd9;
assign exp[0] = -5'sd10;

wire signed [5-1:0] signed_exp_diff;
wire [15-1:0] signed_exp_diff_array[5-1:0];
AND#(15) g3001(signed_exp_diff_array[4], {exp[14][4], exp[13][4], exp[12][4], exp[11][4], exp[10][4], exp[9][4], exp[8][4], exp[7][4], exp[6][4], exp[5][4], exp[4][4], exp[3][4], exp[2][4], exp[1][4], exp[0][4]}, leading_vector, numbers[44]);
AND#(15) g3002(signed_exp_diff_array[3], {exp[14][3], exp[13][3], exp[12][3], exp[11][3], exp[10][3], exp[9][3], exp[8][3], exp[7][3], exp[6][3], exp[5][3], exp[4][3], exp[3][3], exp[2][3], exp[1][3], exp[0][3]}, leading_vector, numbers[45]);
AND#(15) g3003(signed_exp_diff_array[2], {exp[14][2], exp[13][2], exp[12][2], exp[11][2], exp[10][2], exp[9][2], exp[8][2], exp[7][2], exp[6][2], exp[5][2], exp[4][2], exp[3][2], exp[2][2], exp[1][2], exp[0][2]}, leading_vector, numbers[46]);
AND#(15) g3004(signed_exp_diff_array[1], {exp[14][1], exp[13][1], exp[12][1], exp[11][1], exp[10][1], exp[9][1], exp[8][1], exp[7][1], exp[6][1], exp[5][1], exp[4][1], exp[3][1], exp[2][1], exp[1][1], exp[0][1]}, leading_vector, numbers[47]);
AND#(15) g3005(signed_exp_diff_array[0], {exp[14][0], exp[13][0], exp[12][0], exp[11][0], exp[10][0], exp[9][0], exp[8][0], exp[7][0], exp[6][0], exp[5][0], exp[4][0], exp[3][0], exp[2][0], exp[1][0], exp[0][0]}, leading_vector, numbers[48]);

OR#(15)  g4001(signed_exp_diff[4], signed_exp_diff_array[4], numbers[49]);
OR#(15)  g4002(signed_exp_diff[3], signed_exp_diff_array[3], numbers[50]);
OR#(15)  g4003(signed_exp_diff[2], signed_exp_diff_array[2], numbers[51]);
OR#(15)  g4004(signed_exp_diff[1], signed_exp_diff_array[1], numbers[52]);
OR#(15)  g4005(signed_exp_diff[0], signed_exp_diff_array[0], numbers[53]);

// always @(*) begin
//     $display("%b", exp[0][4]);
// end
/* -------------------------- Round to Nearest Even ------------------------- */
wire guard_bit = norm_sum_with_leading1[0];
// reg round_bit, sticky_bit;
// always @(*) begin
//     case (leading_vector)
//         15'b10000_00000_00000: round_bit = unsign_sum[6]; // Decimal point shift 1-bit left (<-)
//         15'b01000_00000_00000: round_bit = unsign_sum[5]; // Decimal point shift 1-bit left (<-)
//         15'b00100_00000_00000: round_bit = unsign_sum[4]; // Decimal point shift 1-bit left (<-)
//         15'b00010_00000_00000: round_bit = unsign_sum[3]; // Decimal point shift 1-bit left (<-)
//         15'b00001_00000_00000: round_bit = unsign_sum[2]; // No shift
//         15'b00000_10000_00000: round_bit = unsign_sum[1]; // Decimal point shift 1-bit right (->)
//         15'b00000_01000_00000: round_bit = unsign_sum[0]; // Decimal point shift 2-bit right (->)
//         default: round_bit = 0;
//     endcase
//     case (leading_vector)
//         15'b10000_00000_00000: sticky_bit = |unsign_sum[5:0]; // Decimal point shift 1-bit left (<-)
//         15'b01000_00000_00000: sticky_bit = |unsign_sum[4:0]; // Decimal point shift 1-bit left (<-)
//         15'b00100_00000_00000: sticky_bit = |unsign_sum[3:0]; // Decimal point shift 1-bit left (<-)
//         15'b00010_00000_00000: sticky_bit = |unsign_sum[2:0]; // Decimal point shift 1-bit left (<-)
//         15'b00001_00000_00000: sticky_bit = |unsign_sum[1:0]; // No shift
//         15'b00000_10000_00000: sticky_bit = |unsign_sum[0]; // Decimal point shift 1-bit right (->)
//         default: sticky_bit = 0;
//     endcase
// end
wire round_bit, sticky_bit;
wire [7-1:0] round_bit_array;
AND#(7) g5001(round_bit_array, unsign_sum[6:0], leading_vector[14:8], numbers[54]);
OR#(7)  g5002(round_bit, round_bit_array, numbers[55]);

wire [6-1:0] sticky_bit_array, sticky_bit_array_real;
assign sticky_bit_array[0] = unsign_sum[0];
OR#(2)  g5003(sticky_bit_array[1], unsign_sum[1:0], numbers[56]);
OR#(3)  g5004(sticky_bit_array[2], unsign_sum[2:0], numbers[57]);
OR#(4)  g5005(sticky_bit_array[3], unsign_sum[3:0], numbers[58]);
OR#(5)  g5006(sticky_bit_array[4], unsign_sum[4:0], numbers[59]);
OR#(6)  g5007(sticky_bit_array[5], unsign_sum[5:0], numbers[60]);

AND#(6) g5008(sticky_bit_array_real, sticky_bit_array, leading_vector[14:9], numbers[61]);
OR#(6)  g5009(sticky_bit, sticky_bit_array_real, numbers[62]);

wire [12-1:0] norm_sum_with_leading1_trun = {1'b0, norm_sum_with_leading1};
wire [12-1:0] norm_sum_with_leading1_incr = norm_sum_with_leading1 + 1'b1;
wire [12-1:0] wire_norm_sum_with_leading1_rne;
reg  [12-1:0] norm_sum_with_leading1_rne;
wire [3:0] grs = {1'b0, guard_bit, round_bit, sticky_bit};

// norm_sum_with_leading1_rne
// | 11 | 10 |  9 |  8 |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
// |         .                                                 |
// always @(*) begin
//     case ({guard_bit, round_bit, sticky_bit})
//         3'b0_00: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
//         3'b0_01: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
//         3'b0_10: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
//         3'b0_11: norm_sum_with_leading1_rne = norm_sum_with_leading1_incr;
//         3'b1_00: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
//         3'b1_01: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
//         3'b1_10: norm_sum_with_leading1_rne = norm_sum_with_leading1_incr;
//         3'b1_11: norm_sum_with_leading1_rne = norm_sum_with_leading1_incr;
//     endcase
// end
always@(*) begin
    norm_sum_with_leading1_rne = wire_norm_sum_with_leading1_rne;
end
wire [0:0] grs_equal01245[4:0];
EQ eq0(grs_equal01245[0], grs, 4'b0000, numbers[70]);
EQ eq1(grs_equal01245[1], grs, 4'b0001, numbers[63]);
EQ eq2(grs_equal01245[2], grs, 4'b0010, numbers[64]);
EQ eq4(grs_equal01245[3], grs, 4'b0100, numbers[65]);
EQ eq5(grs_equal01245[4], grs, 4'b0101, numbers[66]);

wire grs_not_equal01245;
OR#(5) or01245(grs_not_equal01245, grs_equal01245[0], numbers[67]);
MX#(12) mux_result(.o_z(wire_norm_sum_with_leading1_rne), .i_a(norm_sum_with_leading1_trun), .i_b(norm_sum_with_leading1_incr), .i_ctrl(grs_not_equal01245), .number(numbers[68]));

assign exp_carry = norm_sum_with_leading1_rne[11];

// final_norm_sum_with_leading1
// | 10 |  9 |  8 |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
// |    .                                                 |
// assign final_norm_sum_with_leading1 = (norm_sum_with_leading1_rne[11]) ? norm_sum_with_leading1_rne[11:1] : norm_sum_with_leading1_rne[10:0];
MX#(11) mux_final(.o_z(final_norm_sum_with_leading1), .i_a(norm_sum_with_leading1_rne[10:0]), .i_b(norm_sum_with_leading1_rne[11:1]), .i_ctrl(exp_carry), .number(numbers[69]));

reg [50:0] num;
integer j;
always @(*) begin
    num = 0;
    for (j=0; j<71; j=j+1) begin 
        num = num + numbers[j];
    end
end

assign number = num;
endmodule


