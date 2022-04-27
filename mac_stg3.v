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

                input  [15-1:0] i_aligned_pp1,
                input  [15-1:0] i_aligned_pp2,
                input  [15-1:0] i_aligned_pp3,
                input  [15-1:0] i_aligned_pp4,
                input  [15-1:0] i_aligned_pp5,
                input  [15-1:0] i_aligned_pp6,
                input  [15-1:0] i_aligned_pp7,
                input  [15-1:0] i_aligned_pp8,
                input  [15-1:0] i_aligned_pp9,
                input  [ 6-1:0] i_max_exp,

                output [19-1:0] o_psum,
                output 		    o_valid,
                output [ 6-1:0] o_max_exp,
                input  [ 5-1:0] i_Q_frac,
                output [ 5-1:0] o_Q_frac,
                output [50:0] o_transistor_num);

// flags
reg valid_r, valid_w;

// pipeline registers
reg [15-1:0] aligned_pp1_r, aligned_pp1_w;
reg [15-1:0] aligned_pp2_r, aligned_pp2_w;
reg [15-1:0] aligned_pp3_r, aligned_pp3_w;
reg [15-1:0] aligned_pp4_r, aligned_pp4_w;
reg [15-1:0] aligned_pp5_r, aligned_pp5_w;
reg [15-1:0] aligned_pp6_r, aligned_pp6_w;
reg [15-1:0] aligned_pp7_r, aligned_pp7_w;
reg [15-1:0] aligned_pp8_r, aligned_pp8_w;
reg [15-1:0] aligned_pp9_r, aligned_pp9_w;

// maximum exponential term
reg [6-1:0] max_exp_r, max_exp_w;

assign o_max_exp = max_exp_r;
assign o_valid = valid_r;

reg [5-1:0] Q_frac_reg;
assign o_Q_frac = Q_frac_reg;

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
// assign o_psum = $signed(aligned_pp1_r) +
//                 $signed(aligned_pp2_r) +
//                 $signed(aligned_pp3_r) +
//                 $signed(aligned_pp4_r) +
//                 $signed(aligned_pp5_r) +
//                 $signed(aligned_pp6_r) +
//                 $signed(aligned_pp7_r) +
//                 $signed(aligned_pp8_r) +
//                 $signed(aligned_pp9_r);
ADD#(15) add12(.i_a(aligned_pp1_r), .i_b(aligned_pp2_r), .o_s(sum12[14:0], .o_c(sum12[15]), .number(numbers[0])));
ADD#(15) add34(.i_a(aligned_pp3_r), .i_b(aligned_pp4_r), .o_s(sum34[14:0], .o_c(sum34[15]), .number(numbers[1])));
ADD#(15) add56(.i_a(aligned_pp5_r), .i_b(aligned_pp6_r), .o_s(sum56[14:0], .o_c(sum56[15]), .number(numbers[2])));
ADD#(15) add78(.i_a(aligned_pp7_r), .i_b(aligned_pp8_r), .o_s(sum78[14:0], .o_c(sum78[15]), .number(numbers[3])));
ADD#(16) add1234(.i_a(sum12), .i_b(sum34), .o_s(sum1234[15:0], .o_c(sum1234[16]), .number(numbers[4])));
ADD#(17) add5678(.i_a(sum56), .i_b(sum78), .o_s(sum5678[15:0], .o_c(sum5678[16]), .number(numbers[5])));
ADD#(17) add1to8(.i_a(sum1234), .i_b(sum5678), .o_s(sum1to8[16:0], .o_c(sum1to8[17]), .number(numbers[6])));
ADD#(18) add1to9(.i_a(sum1to8), .i_b({3'b0, aligned_pp9_r}), .o_s(sum1to9[16:0], .o_c(sum1to9[17]), .number(numbers[7])));
always@(*) begin
    if (i_inhibit) begin
        valid_w = valid_r;
        aligned_pp1_w = aligned_pp1_r;
        aligned_pp2_w = aligned_pp2_r;
        aligned_pp3_w = aligned_pp3_r;
        aligned_pp4_w = aligned_pp4_r;
        aligned_pp5_w = aligned_pp5_r;
        aligned_pp6_w = aligned_pp6_r;
        aligned_pp7_w = aligned_pp7_r;
        aligned_pp8_w = aligned_pp8_r;
        aligned_pp9_w = aligned_pp9_r;
        max_exp_w = max_exp_r;
    end
    else begin
        valid_w = i_valid;
        aligned_pp1_w = i_aligned_pp1;
        aligned_pp2_w = i_aligned_pp2;
        aligned_pp3_w = i_aligned_pp3;
        aligned_pp4_w = i_aligned_pp4;
        aligned_pp5_w = i_aligned_pp5;
        aligned_pp6_w = i_aligned_pp6;
        aligned_pp7_w = i_aligned_pp7;
        aligned_pp8_w = i_aligned_pp8;
        aligned_pp9_w = i_aligned_pp9;
        max_exp_w = i_max_exp;
    end
end

always@(posedge i_clk  or negedge i_rst_n) begin
    if (~i_rst_n) begin
        valid_r <= 0;
        aligned_pp1_r <= 0;
        aligned_pp2_r <= 0;
        aligned_pp3_r <= 0;
        aligned_pp4_r <= 0;
        aligned_pp5_r <= 0;
        aligned_pp6_r <= 0;
        aligned_pp7_r <= 0;
        aligned_pp8_r <= 0;
        aligned_pp9_r <= 0;
        max_exp_r <= 0;
        Q_frac_reg <= 0;
    end
    else begin
        valid_r <= valid_w;
        aligned_pp1_r <= aligned_pp1_w;
        aligned_pp2_r <= aligned_pp2_w;
        aligned_pp3_r <= aligned_pp3_w;
        aligned_pp4_r <= aligned_pp4_w;
        aligned_pp5_r <= aligned_pp5_w;
        aligned_pp6_r <= aligned_pp6_w;
        aligned_pp7_r <= aligned_pp7_w;
        aligned_pp8_r <= aligned_pp8_w;
        aligned_pp9_r <= aligned_pp9_w;
        max_exp_r <= max_exp_w;
        Q_frac_reg <= i_Q_frac;
    end
end
assign o_transistor_num = 0;
endmodule
