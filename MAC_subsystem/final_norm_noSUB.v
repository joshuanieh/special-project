module final_norm_noSUB(
           input  [19-1:0] sum,
           output [11-1:0] final_norm_sum_with_leading1,
           output [ 5-1:0] signed_exp_diff,
           output exp_carry,
           output sign
       );


// unsign_sum
//                    exp_diff = 11    ----->                               |  2 | 1 | 0 |
//                                                                          | ld .       |
//      |<--                       leading_vector                       --> |
// | 18 | 17 | 16 | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 |  2 | 1 | 0 |
// |  0 |                        .                                        G |  R   S     |
assign sign = sum[18];
wire [19-1:0] unsign_sum = (sign) ? ~sum + 1'b1 : sum;


/* --------------------- Normalized Sum with Leading One -------------------- */
wire [15-1:0] leading_vector;
assign leading_vector[14] = unsign_sum[17];
assign leading_vector[13] = ( (|unsign_sum[17]    == 0) && (unsign_sum[16] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[12] = ( (|unsign_sum[17:16] == 0) && (unsign_sum[15] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[11] = ( (|unsign_sum[17:15] == 0) && (unsign_sum[14] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[10] = ( (|unsign_sum[17:14] == 0) && (unsign_sum[13] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 9] = ( (|unsign_sum[17:13] == 0) && (unsign_sum[12] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 8] = ( (|unsign_sum[17:12] == 0) && (unsign_sum[11] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 7] = ( (|unsign_sum[17:11] == 0) && (unsign_sum[10] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 6] = ( (|unsign_sum[17:10] == 0) && (unsign_sum[ 9] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 5] = ( (|unsign_sum[17: 9] == 0) && (unsign_sum[ 8] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 4] = ( (|unsign_sum[17: 8] == 0) && (unsign_sum[ 7] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 3] = ( (|unsign_sum[17: 7] == 0) && (unsign_sum[ 6] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 2] = ( (|unsign_sum[17: 6] == 0) && (unsign_sum[ 5] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 1] = ( (|unsign_sum[17: 5] == 0) && (unsign_sum[ 4] == 1'b1) ) ? 1'b1 : 0;
assign leading_vector[ 0] = ( (|unsign_sum[17: 4] == 0) && (unsign_sum[ 3] == 1'b1) ) ? 1'b1 : 0;


// norm_sum_with_leading1
// | 10 |  9 |  8 |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
// |    .                                            | GB |
reg [11-1:0] norm_sum_with_leading1;
always @(*) begin
    case (leading_vector)
        15'b10000_00000_00000: norm_sum_with_leading1 = unsign_sum[17: 7]; // Decimal point shift 4-bit left  (<-)
        15'b01000_00000_00000: norm_sum_with_leading1 = unsign_sum[16: 6]; // Decimal point shift 3-bit left  (<-)
        15'b00100_00000_00000: norm_sum_with_leading1 = unsign_sum[15: 5]; // Decimal point shift 2-bit left  (<-)
        15'b00010_00000_00000: norm_sum_with_leading1 = unsign_sum[14: 4]; // Decimal point shift 1-bit left  (<-)
        15'b00001_00000_00000: norm_sum_with_leading1 = unsign_sum[13: 3]; // No shift
        15'b00000_10000_00000: norm_sum_with_leading1 = unsign_sum[12: 2]; // Decimal point shift 1-bit right (->)
        15'b00000_01000_00000: norm_sum_with_leading1 = unsign_sum[11: 1]; // Decimal point shift 2-bit right (->)
        15'b00000_00100_00000: norm_sum_with_leading1 = unsign_sum[10: 0]; // Decimal point shift 3-bit right (->)

        15'b00000_00010_00000: norm_sum_with_leading1 = {unsign_sum[ 9: 0], 1'd0}; // Decimal point shift 4-bit right (->)
        15'b00000_00001_00000: norm_sum_with_leading1 = {unsign_sum[ 8: 0], 2'd0}; // Decimal point shift 5-bit right (->)
        15'b00000_00000_10000: norm_sum_with_leading1 = {unsign_sum[ 7: 0], 3'd0}; // Decimal point shift 6-bit right (->)
        15'b00000_00000_01000: norm_sum_with_leading1 = {unsign_sum[ 6: 0], 4'd0}; // Decimal point shift 7-bit right (->)
        15'b00000_00000_00100: norm_sum_with_leading1 = {unsign_sum[ 5: 0], 5'd0}; // Decimal point shift 8-bit right (->)
        15'b00000_00000_00010: norm_sum_with_leading1 = {unsign_sum[ 4: 0], 6'd0}; // Decimal point shift 9-bit right (->)
        15'b00000_00000_00001: norm_sum_with_leading1 = {unsign_sum[ 3: 0], 7'd0}; // Decimal point shift 10-bit right
        default: norm_sum_with_leading1 = 11'd0;
    endcase
end

// Change exp according to decimal point shift
reg signed [5-1:0] signed_exp_diff;
always @(*) begin
    case (leading_vector)
        15'b10000_00000_00000: signed_exp_diff =  5'sd4 ; // Decimal point shift 4-bit left (<-)
        15'b01000_00000_00000: signed_exp_diff =  5'sd3 ; // Decimal point shift 3-bit left (<-)
        15'b00100_00000_00000: signed_exp_diff =  5'sd2 ; // Decimal point shift 2-bit left (<-)
        15'b00010_00000_00000: signed_exp_diff =  5'sd1 ; // Decimal point shift 1-bit left (<-)
        15'b00001_00000_00000: signed_exp_diff =  5'sd0 ; // No shift
        15'b00000_10000_00000: signed_exp_diff = -5'sd1 ; // Decimal point shift 1-bit right (->)
        15'b00000_01000_00000: signed_exp_diff = -5'sd2 ; // Decimal point shift 2-bit right (->)
        15'b00000_00100_00000: signed_exp_diff = -5'sd3 ; // Decimal point shift 3-bit right (->)
        15'b00000_00010_00000: signed_exp_diff = -5'sd4 ; // Decimal point shift 4-bit right (->)
        15'b00000_00001_00000: signed_exp_diff = -5'sd5 ; // Decimal point shift 5-bit right (->)
        15'b00000_00000_10000: signed_exp_diff = -5'sd6 ; // Decimal point shift 6-bit right (->)
        15'b00000_00000_01000: signed_exp_diff = -5'sd7 ; // Decimal point shift 7-bit right (->)
        15'b00000_00000_00100: signed_exp_diff = -5'sd8 ; // Decimal point shift 8-bit right (->)
        15'b00000_00000_00010: signed_exp_diff = -5'sd9 ; // Decimal point shift 9-bit right (->)
        15'b00000_00000_00001: signed_exp_diff = -5'sd10; // Decimal point shift 10-bit right (->)
        default: signed_exp_diff = 5'sd0;
    endcase
end

/* -------------------------- Round to Nearest Even ------------------------- */
wire guard_bit = norm_sum_with_leading1[0];
reg round_bit, sticky_bit;
always @(*) begin
    case (leading_vector)
        15'b10000_00000_00000: round_bit = unsign_sum[6]; // Decimal point shift 1-bit left (<-)
        15'b01000_00000_00000: round_bit = unsign_sum[5]; // Decimal point shift 1-bit left (<-)
        15'b00100_00000_00000: round_bit = unsign_sum[4]; // Decimal point shift 1-bit left (<-)
        15'b00010_00000_00000: round_bit = unsign_sum[3]; // Decimal point shift 1-bit left (<-)
        15'b00001_00000_00000: round_bit = unsign_sum[2]; // No shift
        15'b00000_10000_00000: round_bit = unsign_sum[1]; // Decimal point shift 1-bit right (->)
        15'b00000_01000_00000: round_bit = unsign_sum[0]; // Decimal point shift 2-bit right (->)
        default: round_bit = 0;
    endcase
    case (leading_vector)
        15'b10000_00000_00000: sticky_bit = |unsign_sum[5:0]; // Decimal point shift 1-bit left (<-)
        15'b01000_00000_00000: sticky_bit = |unsign_sum[4:0]; // Decimal point shift 1-bit left (<-)
        15'b00100_00000_00000: sticky_bit = |unsign_sum[3:0]; // Decimal point shift 1-bit left (<-)
        15'b00010_00000_00000: sticky_bit = |unsign_sum[2:0]; // Decimal point shift 1-bit left (<-)
        15'b00001_00000_00000: sticky_bit = |unsign_sum[1:0]; // No shift
        15'b00000_10000_00000: sticky_bit = |unsign_sum[0]; // Decimal point shift 1-bit right (->)
        default: sticky_bit = 0;
    endcase
end


wire [12-1:0] norm_sum_with_leading1_trun = {1'b0, norm_sum_with_leading1};
wire [12-1:0] norm_sum_with_leading1_incr = norm_sum_with_leading1 + 1'b1;
reg  [12-1:0] norm_sum_with_leading1_rne;

// norm_sum_with_leading1_rne
// | 11 | 10 |  9 |  8 |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
// |         .                                                 |
always @(*) begin
    case ({guard_bit, round_bit, sticky_bit})
        3'b0_00: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
        3'b0_01: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
        3'b0_10: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
        3'b0_11: norm_sum_with_leading1_rne = norm_sum_with_leading1_incr;
        3'b1_00: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
        3'b1_01: norm_sum_with_leading1_rne = norm_sum_with_leading1_trun;
        3'b1_10: norm_sum_with_leading1_rne = norm_sum_with_leading1_incr;
        3'b1_11: norm_sum_with_leading1_rne = norm_sum_with_leading1_incr;
    endcase
end

assign exp_carry = norm_sum_with_leading1_rne[11];

// final_norm_sum_with_leading1
// | 10 |  9 |  8 |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
// |    .                                                 |
assign final_norm_sum_with_leading1 = (norm_sum_with_leading1_rne[11]) ? norm_sum_with_leading1_rne[11:1] : norm_sum_with_leading1_rne[10:0];


endmodule


