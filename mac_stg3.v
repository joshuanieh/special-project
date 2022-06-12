/**************************************************************************************************
*    File Name:  mac.v
*      Version:  6.0.0
*      Arthors:  Lin, Juang, Kung
*
*  Dependecies:  
*
*  Description:  Adder to summing up all the 18 partial products.
*
*      Details:  - i_im vectors  --> 1+4-bit mantissa, 5-bit exp
*                - i_ker vectors --> 6-bit mantissa (2 groups), 1+2-bit exp.
*                - update_mode   --> use gradient as weight, need to realign activation.
*                - Q_frac        --> float dot offset (9-bit), start from MSB
*
* Rev     Author   Date          Changes
* ---------------------------------------------------------------------------------------
* older   Lin      ----/--/--    ---
* 5.0.0   Juang    2018/04/28    Changed i_im inputs to 10-bit format.
*                                Changed i_ker inputs to 10-bit format.
*                                Added update mode to realign gradient
*                                Added Q_frac.
* 5.0.1   Juang    2018/05/05    Changed i_ker inputs to 9-bit format.
* 5.0.2   Juang    2018/06/03    Changed i_im inputs to 9-bit format.
* 5.1.0   Juang    2018/06/23    Changed to 8-bit format (2 bpg + 3 bpg)
* 5.1.1   Kung     2019/02/26    Change Datapath to 16-bit
*								 Change i_aligned_pp* to 12 bits              
* 6.0.0   Hsieh    2020/11/02    Change to 4-bit FloatSD4 weight
**************************************************************************************************/

module mac_stg3(input           i_clk,
                input           i_rst_n,
                input           i_valid,
                input           i_inhibit,

                input           i_pp_sign1,
                input           i_pp_sign2,
                input           i_pp_sign3,
                input           i_pp_sign4,
                input           i_pp_sign5,
                input           i_pp_sign6,
                input           i_pp_sign7,
                input           i_pp_sign8,
                input           i_pp_sign9,
                input  [14-1:0] i_shifted_unsign_pp1,
                input  [14-1:0] i_shifted_unsign_pp2,
                input  [14-1:0] i_shifted_unsign_pp3,
                input  [14-1:0] i_shifted_unsign_pp4,
                input  [14-1:0] i_shifted_unsign_pp5,
                input  [14-1:0] i_shifted_unsign_pp6,
                input  [14-1:0] i_shifted_unsign_pp7,
                input  [14-1:0] i_shifted_unsign_pp8,
                input  [14-1:0] i_shifted_unsign_pp9,
                input  [ 6-1:0] i_max_exp,

                // output [19-1:0] o_psum,
                output [19-1:0] o_extend_sum1234,
                output [19-1:0] o_extend_sum5678,
                output 		    o_valid,
                output [ 6-1:0] o_max_exp,
                input  [ 5-1:0] i_Q_frac,
                output [ 5-1:0] o_Q_frac,
                output [50:0]   o_transistor_num);
wire [50:0] numbers[0:100];

// flags
reg valid_r, valid_w;

// pipeline registers
reg pp_sign1_r, pp_sign1_w;
reg pp_sign2_r, pp_sign2_w;
reg pp_sign3_r, pp_sign3_w;
reg pp_sign4_r, pp_sign4_w;
reg pp_sign5_r, pp_sign5_w;
reg pp_sign6_r, pp_sign6_w;
reg pp_sign7_r, pp_sign7_w;
reg pp_sign8_r, pp_sign8_w;
reg pp_sign9_r, pp_sign9_w;
reg [14-1:0] shifted_unsign_pp1_r, shifted_unsign_pp1_w;
reg [14-1:0] shifted_unsign_pp2_r, shifted_unsign_pp2_w;
reg [14-1:0] shifted_unsign_pp3_r, shifted_unsign_pp3_w;
reg [14-1:0] shifted_unsign_pp4_r, shifted_unsign_pp4_w;
reg [14-1:0] shifted_unsign_pp5_r, shifted_unsign_pp5_w;
reg [14-1:0] shifted_unsign_pp6_r, shifted_unsign_pp6_w;
reg [14-1:0] shifted_unsign_pp7_r, shifted_unsign_pp7_w;
reg [14-1:0] shifted_unsign_pp8_r, shifted_unsign_pp8_w;
reg [14-1:0] shifted_unsign_pp9_r, shifted_unsign_pp9_w;

// maximum exponential term
reg [6-1:0] max_exp_r, max_exp_w;

assign o_max_exp = max_exp_r;
assign o_valid = valid_r;

reg [5-1:0] Q_frac_reg;
assign o_Q_frac = Q_frac_reg;

//2's complements
wire [15-1:0] inv_tmp_1, negative_num_1, align_pp1;
wire whatsoever1;
INV#(15) inv_101(
    .i_a({1'b0, shifted_unsign_pp1_r}),
    .o_z(inv_tmp_1),
    .number(numbers[0])
);

ADD#(15) add_101(
    .i_a(inv_tmp_1),
    .i_b(15'b1),
    .o_s(negative_num_1),
    .o_c(whatsoever1),
    .number(numbers[1])
);

MX#(15) mux_align_pp1(align_pp1, {1'b0, shifted_unsign_pp1_r}, negative_num_1, pp_sign1_r, numbers[2]);

//2's complements
wire [15-1:0] inv_tmp_2, negative_num_2, align_pp2;
wire whatsoever2;
INV#(15) inv_102(
    .i_a({1'b0, shifted_unsign_pp2_r}),
    .o_z(inv_tmp_2),
    .number(numbers[3])
);

ADD#(15) add_102(
    .i_a(inv_tmp_2),
    .i_b(15'b1),
    .o_s(negative_num_2),
    .o_c(whatsoever2),
    .number(numbers[4])
);

MX#(15) mux_align_pp2(align_pp2, {1'b0, shifted_unsign_pp2_r}, negative_num_2, pp_sign2_r, numbers[5]);

//2's complements
wire [15-1:0] inv_tmp_3, negative_num_3, align_pp3;
wire whatsoever3;
INV#(15) inv_103(
    .i_a({1'b0, shifted_unsign_pp3_r}),
    .o_z(inv_tmp_3),
    .number(numbers[6])
);

ADD#(15) add_103(
    .i_a(inv_tmp_3),
    .i_b(15'b1),
    .o_s(negative_num_3),
    .o_c(whatsoever3),
    .number(numbers[7])
);

MX#(15) mux_align_pp3(align_pp3, {1'b0, shifted_unsign_pp3_r}, negative_num_3, pp_sign3_r, numbers[8]);

//2's complements
wire [15-1:0] inv_tmp_4, negative_num_4, align_pp4;
wire whatsoever4;
INV#(15) inv_104(
    .i_a({1'b0, shifted_unsign_pp4_r}),
    .o_z(inv_tmp_4),
    .number(numbers[9])
);

ADD#(15) add_104(
    .i_a(inv_tmp_4),
    .i_b(15'b1),
    .o_s(negative_num_4),
    .o_c(whatsoever4),
    .number(numbers[10])
);

MX#(15) mux_align_pp4(align_pp4, {1'b0, shifted_unsign_pp4_r}, negative_num_4, pp_sign4_r, numbers[11]);

//2's complements
wire [15-1:0] inv_tmp_5, negative_num_5, align_pp5;
wire whatsoever5;
INV#(15) inv_105(
    .i_a({1'b0, shifted_unsign_pp5_r}),
    .o_z(inv_tmp_5),
    .number(numbers[12])
);

ADD#(15) add_105(
    .i_a(inv_tmp_5),
    .i_b(15'b1),
    .o_s(negative_num_5),
    .o_c(whatsoever5),
    .number(numbers[13])
);

MX#(15) mux_align_pp5(align_pp5, {1'b0, shifted_unsign_pp5_r}, negative_num_5, pp_sign5_r, numbers[14]);

//2's complements
wire [15-1:0] inv_tmp_6, negative_num_6, align_pp6;
wire whatsoever6;
INV#(15) inv_106(
    .i_a({1'b0, shifted_unsign_pp6_r}),
    .o_z(inv_tmp_6),
    .number(numbers[15])
);

ADD#(15) add_106(
    .i_a(inv_tmp_6),
    .i_b(15'b1),
    .o_s(negative_num_6),
    .o_c(whatsoever6),
    .number(numbers[16])
);

MX#(15) mux_align_pp6(align_pp6, {1'b0, shifted_unsign_pp6_r}, negative_num_6, pp_sign6_r, numbers[17]);

//2's complements
wire [15-1:0] inv_tmp_7, negative_num_7, align_pp7;
wire whatsoever7;
INV#(15) inv_107(
    .i_a({1'b0, shifted_unsign_pp7_r}),
    .o_z(inv_tmp_7),
    .number(numbers[18])
);

ADD#(15) add_107(
    .i_a(inv_tmp_7),
    .i_b(15'b1),
    .o_s(negative_num_7),
    .o_c(whatsoever7),
    .number(numbers[19])
);

MX#(15) mux_align_pp7(align_pp7, {1'b0, shifted_unsign_pp7_r}, negative_num_7, pp_sign7_r, numbers[20]);

//2's complements
wire [15-1:0] inv_tmp_8, negative_num_8, align_pp8;
wire whatsoever8;
INV#(15) inv_108(
    .i_a({1'b0, shifted_unsign_pp8_r}),
    .o_z(inv_tmp_8),
    .number(numbers[21])
);

ADD#(15) add_108(
    .i_a(inv_tmp_8),
    .i_b(15'b1),
    .o_s(negative_num_8),
    .o_c(whatsoever8),
    .number(numbers[22])
);

MX#(15) mux_align_pp8(align_pp8, {1'b0, shifted_unsign_pp8_r}, negative_num_8, pp_sign8_r, numbers[23]);

//2's complements
wire [15-1:0] inv_tmp_9, negative_num_9, align_pp9;
wire whatsoever9;
INV#(15) inv_109(
    .i_a({1'b0, shifted_unsign_pp9_r}),
    .o_z(inv_tmp_9),
    .number(numbers[24])
);

ADD#(15) add_109(
    .i_a(inv_tmp_9),
    .i_b(15'b1),
    .o_s(negative_num_9),
    .o_c(whatsoever9),
    .number(numbers[25])
);

MX#(15) mux_align_pp9(align_pp9, {1'b0, shifted_unsign_pp9_r}, negative_num_9, pp_sign9_r, numbers[26]);

// i_aligned_pp
//                    exp_diff = 11    ----->           |  2 | 1 | 0 |
//                                                      | ld .       |
// | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 |  2 | 1 | 0 |
// |  S |    .                                        G |  R   S     |

// Debug
// o_psum
//                    exp_diff = 11    ----->                               |  2 | 1 | 0 |
//                                                                          | ld .       |
// | 18 | 17 | 16 | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 |  2 | 1 | 0 |
// |  S |                        .                                        G |  R   S     |
wire [16-1:0] sum12, sum34, sum56, sum78;
wire [17-1:0] sum1234, sum5678;
wire [18-1:0] sum1to8;
// assign o_psum = $signed(align_pp1) +
//                 $signed(align_pp2) +
//                 $signed(align_pp3) +
//                 $signed(align_pp4) +
//                 $signed(align_pp5) +
//                 $signed(align_pp6) +
//                 $signed(align_pp7) +
//                 $signed(align_pp8) +
//                 $signed(align_pp9);
wire [7:0] garbage_carry;
ADD#(16) add12(.i_a({align_pp1[14], align_pp1}), .i_b({align_pp2[14], align_pp2}), .o_s(sum12[15:0]), .o_c(garbage_carry[0]), .number(numbers[27]));
ADD#(16) add34(.i_a({align_pp3[14], align_pp3}), .i_b({align_pp4[14], align_pp4}), .o_s(sum34[15:0]), .o_c(garbage_carry[1]), .number(numbers[28]));
ADD#(16) add56(.i_a({align_pp5[14], align_pp5}), .i_b({align_pp6[14], align_pp6}), .o_s(sum56[15:0]), .o_c(garbage_carry[2]), .number(numbers[29]));
ADD#(16) add78(.i_a({align_pp7[14], align_pp7}), .i_b({align_pp8[14], align_pp8}), .o_s(sum78[15:0]), .o_c(garbage_carry[3]), .number(numbers[30]));
ADD#(17) add1234(.i_a({sum12[15], sum12}), .i_b({sum34[15], sum34}), .o_s(sum1234[16:0]), .o_c(garbage_carry[4]), .number(numbers[31]));
ADD#(17) add5678(.i_a({sum56[15], sum56}), .i_b({sum78[15], sum78}), .o_s(sum5678[16:0]), .o_c(garbage_carry[5]), .number(numbers[32]));
ADD#(18) add1to8(.i_a({sum1234[16], sum1234}), .i_b({sum5678[16], sum5678}), .o_s(sum1to8[17:0]), .o_c(garbage_carry[6]), .number(numbers[33]));
// ADD#(19) add1to9(.i_a({sum1to8[17], sum1to8}), .i_b({{4{align_pp9[14]}}, align_pp9}), .o_s(o_psum[18:0]), .o_c(garbage_carry[7]), .number(numbers[7]));
assign o_extend_sum1234 = {sum1to8[17], sum1to8};
assign o_extend_sum5678 = {{4{align_pp9[14]}}, align_pp9};

always@(*) begin
    if (i_inhibit) begin
        valid_w = valid_r;
        pp_sign1_w = pp_sign1_r;
        pp_sign2_w = pp_sign2_r;
        pp_sign3_w = pp_sign3_r;
        pp_sign4_w = pp_sign4_r;
        pp_sign5_w = pp_sign5_r;
        pp_sign6_w = pp_sign6_r;
        pp_sign7_w = pp_sign7_r;
        pp_sign8_w = pp_sign8_r;
        pp_sign9_w = pp_sign9_r;
        shifted_unsign_pp1_w = shifted_unsign_pp1_r;
        shifted_unsign_pp2_w = shifted_unsign_pp2_r;
        shifted_unsign_pp3_w = shifted_unsign_pp3_r;
        shifted_unsign_pp4_w = shifted_unsign_pp4_r;
        shifted_unsign_pp5_w = shifted_unsign_pp5_r;
        shifted_unsign_pp6_w = shifted_unsign_pp6_r;
        shifted_unsign_pp7_w = shifted_unsign_pp7_r;
        shifted_unsign_pp8_w = shifted_unsign_pp8_r;
        shifted_unsign_pp9_w = shifted_unsign_pp9_r;
        max_exp_w = max_exp_r;
    end
    else begin
        valid_w = i_valid;
        pp_sign1_w = i_pp_sign1;
        pp_sign2_w = i_pp_sign2;
        pp_sign3_w = i_pp_sign3;
        pp_sign4_w = i_pp_sign4;
        pp_sign5_w = i_pp_sign5;
        pp_sign6_w = i_pp_sign6;
        pp_sign7_w = i_pp_sign7;
        pp_sign8_w = i_pp_sign8;
        pp_sign9_w = i_pp_sign9;
        shifted_unsign_pp1_w = i_shifted_unsign_pp1;
        shifted_unsign_pp2_w = i_shifted_unsign_pp2;
        shifted_unsign_pp3_w = i_shifted_unsign_pp3;
        shifted_unsign_pp4_w = i_shifted_unsign_pp4;
        shifted_unsign_pp5_w = i_shifted_unsign_pp5;
        shifted_unsign_pp6_w = i_shifted_unsign_pp6;
        shifted_unsign_pp7_w = i_shifted_unsign_pp7;
        shifted_unsign_pp8_w = i_shifted_unsign_pp8;
        shifted_unsign_pp9_w = i_shifted_unsign_pp9;
        max_exp_w = i_max_exp;
    end
end

always@(posedge i_clk  or negedge i_rst_n) begin
    if (~i_rst_n) begin
        valid_r <= 0;
        pp_sign1_r <= 0;
        pp_sign2_r <= 0;
        pp_sign3_r <= 0;
        pp_sign4_r <= 0;
        pp_sign5_r <= 0;
        pp_sign6_r <= 0;
        pp_sign7_r <= 0;
        pp_sign8_r <= 0;
        pp_sign9_r <= 0;
        shifted_unsign_pp1_r <= 0;
        shifted_unsign_pp2_r <= 0;
        shifted_unsign_pp3_r <= 0;
        shifted_unsign_pp4_r <= 0;
        shifted_unsign_pp5_r <= 0;
        shifted_unsign_pp6_r <= 0;
        shifted_unsign_pp7_r <= 0;
        shifted_unsign_pp8_r <= 0;
        shifted_unsign_pp9_r <= 0;
        max_exp_r <= 0;
        Q_frac_reg <= 0;
    end
    else begin
        valid_r <= valid_w;
        pp_sign1_r <= pp_sign1_w;
        pp_sign2_r <= pp_sign2_w;
        pp_sign3_r <= pp_sign3_w;
        pp_sign4_r <= pp_sign4_w;
        pp_sign5_r <= pp_sign5_w;
        pp_sign6_r <= pp_sign6_w;
        pp_sign7_r <= pp_sign7_w;
        pp_sign8_r <= pp_sign8_w;
        pp_sign9_r <= pp_sign9_w;
        shifted_unsign_pp1_r <= shifted_unsign_pp1_w;
        shifted_unsign_pp2_r <= shifted_unsign_pp2_w;
        shifted_unsign_pp3_r <= shifted_unsign_pp3_w;
        shifted_unsign_pp4_r <= shifted_unsign_pp4_w;
        shifted_unsign_pp5_r <= shifted_unsign_pp5_w;
        shifted_unsign_pp6_r <= shifted_unsign_pp6_w;
        shifted_unsign_pp7_r <= shifted_unsign_pp7_w;
        shifted_unsign_pp8_r <= shifted_unsign_pp8_w;
        shifted_unsign_pp9_r <= shifted_unsign_pp9_w;
        max_exp_r <= max_exp_w;
        Q_frac_reg <= i_Q_frac;
    end
end

reg [50:0] sum;
integer j;
always @(*) begin
    sum = 0;
    for (j=0; j<34; j=j+1) begin 
        sum = sum + numbers[j];
    end
end

assign o_transistor_num = sum + 147 * 27;
endmodule
