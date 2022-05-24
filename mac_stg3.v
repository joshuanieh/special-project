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

                output [19-1:0] o_psum,
                output 		    o_valid,
                output [ 6-1:0] o_max_exp,
                input  [ 5-1:0] i_Q_frac,
                output [ 5-1:0] o_Q_frac,
                output [50:0] o_transistor_num);
wire [50:0] numbers[0:10];

// flags
reg valid_r, valid_w;

// pipeline registers
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
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp1_r}),
    .o_z(inv_tmp_1),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_1),
    .i_b(15'b1),
    .o_s(negative_num_1),
    .o_c(whatsoever1),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp1, {1'b0, shifted_unsign_pp1_r}, negative_num_1, i_pp_sign1, numbers[16]);

//2's complements
wire [15-1:0] inv_tmp_2, negative_num_2, align_pp2;
wire whatsoever2;
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp2_r}),
    .o_z(inv_tmp_2),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_2),
    .i_b(15'b1),
    .o_s(negative_num_2),
    .o_c(whatsoever2),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp2, {1'b0, shifted_unsign_pp1_r}, negative_num_2, i_pp_sign2, numbers[16]);

//2's complements
wire [15-1:0] inv_tmp_3, negative_num_3, align_pp3;
wire whatsoever3;
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp3_r}),
    .o_z(inv_tmp_3),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_3),
    .i_b(15'b1),
    .o_s(negative_num_3),
    .o_c(whatsoever3),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp3, {1'b0, shifted_unsign_pp1_r}, negative_num_3, i_pp_sign3, numbers[16]);

//2's complements
wire [15-1:0] inv_tmp_4, negative_num_4, align_pp4;
wire whatsoever4;
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp4_r}),
    .o_z(inv_tmp_4),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_4),
    .i_b(15'b1),
    .o_s(negative_num_4),
    .o_c(whatsoever4),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp4, {1'b0, shifted_unsign_pp1_r}, negative_num_4, i_pp_sign4, numbers[16]);

//2's complements
wire [15-1:0] inv_tmp_5, negative_num_5, align_pp5;
wire whatsoever5;
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp5_r}),
    .o_z(inv_tmp_5),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_5),
    .i_b(15'b1),
    .o_s(negative_num_5),
    .o_c(whatsoever5),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp5, {1'b0, shifted_unsign_pp1_r}, negative_num_5, i_pp_sign5, numbers[16]);

//2's complements
wire [15-1:0] inv_tmp_6, negative_num_6, align_pp6;
wire whatsoever6;
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp6_r}),
    .o_z(inv_tmp_6),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_6),
    .i_b(15'b1),
    .o_s(negative_num_6),
    .o_c(whatsoever6),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp6, {1'b0, shifted_unsign_pp1_r}, negative_num_6, i_pp_sign6, numbers[16]);

//2's complements
wire [15-1:0] inv_tmp_7, negative_num_7, align_pp7;
wire whatsoever7;
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp7_r}),
    .o_z(inv_tmp_7),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_7),
    .i_b(15'b1),
    .o_s(negative_num_7),
    .o_c(whatsoever7),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp7, {1'b0, shifted_unsign_pp1_r}, negative_num_7, i_pp_sign7, numbers[16]);

//2's complements
wire [15-1:0] inv_tmp_8, negative_num_8, align_pp8;
wire whatsoever8;
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp8_r}),
    .o_z(inv_tmp_8),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_8),
    .i_b(15'b1),
    .o_s(negative_num_8),
    .o_c(whatsoever8),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp8, {1'b0, shifted_unsign_pp1_r}, negative_num_8, i_pp_sign8, numbers[16]);

//2's complements
wire [15-1:0] inv_tmp_9, negative_num_9, align_pp9;
wire whatsoever9;
INV#(15) inv_100(
    .i_a({1'b0, shifted_unsign_pp9_r}),
    .o_z(inv_tmp_9),
    .number(numbers[14])
);

ADD#(15) add_100(
    .i_a(inv_tmp_9),
    .i_b(15'b1),
    .o_s(negative_num_9),
    .o_c(whatsoever9),
    .number(numbers[15])
);

MX#(15) mux_align_pp(align_pp9, {1'b0, shifted_unsign_pp1_r}, negative_num_9, i_pp_sign9, numbers[16]);

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
// assign o_psum = $signed(shifted_unsign_pp1_r) +
//                 $signed(shifted_unsign_pp2_r) +
//                 $signed(shifted_unsign_pp3_r) +
//                 $signed(shifted_unsign_pp4_r) +
//                 $signed(shifted_unsign_pp5_r) +
//                 $signed(shifted_unsign_pp6_r) +
//                 $signed(shifted_unsign_pp7_r) +
//                 $signed(shifted_unsign_pp8_r) +
//                 $signed(shifted_unsign_pp9_r);
wire [7:0] garbage_carry;
ADD#(16) add12(.i_a({aligned_pp1[14], aligned_pp1}), .i_b({aligned_pp2[14], aligned_pp2}), .o_s(sum12[15:0]), .o_c(garbage_carry[0]), .number(numbers[0]));
ADD#(16) add34(.i_a({aligned_pp3[14], aligned_pp3}), .i_b({aligned_pp4[14], aligned_pp4}), .o_s(sum34[15:0]), .o_c(garbage_carry[1]), .number(numbers[1]));
ADD#(16) add56(.i_a({aligned_pp5[14], aligned_pp5}), .i_b({aligned_pp6[14], aligned_pp6}), .o_s(sum56[15:0]), .o_c(garbage_carry[2]), .number(numbers[2]));
ADD#(16) add78(.i_a({aligned_pp7[14], aligned_pp7}), .i_b({aligned_pp8[14], aligned_pp8}), .o_s(sum78[15:0]), .o_c(garbage_carry[3]), .number(numbers[3]));
ADD#(17) add1234(.i_a({sum12[15], sum12}), .i_b({sum34[15], sum34}), .o_s(sum1234[16:0]), .o_c(garbage_carry[4]), .number(numbers[4]));
ADD#(17) add5678(.i_a({sum56[15], sum56}), .i_b({sum78[15], sum78}), .o_s(sum5678[16:0]), .o_c(garbage_carry[5]), .number(numbers[5]));
ADD#(18) add1to8(.i_a({sum1234[16], sum1234}), .i_b({sum5678[16], sum5678}), .o_s(sum1to8[17:0]), .o_c(garbage_carry[6]), .number(numbers[6]));
ADD#(19) add1to9(.i_a({sum1to8[17], sum1to8}), .i_b({{4{aligned_pp9[14]}}, aligned_pp9}), .o_s(o_psum[18:0]), .o_c(garbage_carry[7]), .number(numbers[7]));
always@(*) begin
    if (i_inhibit) begin
        valid_w = valid_r;
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
    for (j=0; j<8; j=j+1) begin 
        sum = sum + numbers[j];
    end
end

assign o_transistor_num = sum;
endmodule
