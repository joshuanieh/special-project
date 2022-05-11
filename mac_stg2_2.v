/**************************************************************************************************
*    File Name:  mac_stg2.v
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
*								 Change o_aligned_pp* to 12 bits    
*								 Change i_pp* to 11 bits          
* 6.0.0   Hsieh    2020/11/02    Change to 4-bit FloatSD4 weight
**************************************************************************************************/
module mac_stg2_2(
                input           i_clk,
                input           i_rst_n,
                input           i_valid,
                input           i_inhibit,
                
                input  [ 6-1:0] i_max_exp,
                input  [14-1:0] i_shifted_unsign_pp1,
                input  [14-1:0] i_shifted_unsign_pp2,
                input  [14-1:0] i_shifted_unsign_pp3,
                input  [14-1:0] i_shifted_unsign_pp4,
                input  [14-1:0] i_shifted_unsign_pp5,
                input  [14-1:0] i_shifted_unsign_pp6,
                input  [14-1:0] i_shifted_unsign_pp7,
                input  [14-1:0] i_shifted_unsign_pp8,
                input  [14-1:0] i_shifted_unsign_pp9,
                input           i_pp_sign1,
                input           i_pp_sign2,
                input           i_pp_sign3,
                input           i_pp_sign4,
                input           i_pp_sign5,
                input           i_pp_sign6,
                input           i_pp_sign7,
                input           i_pp_sign8,
                input           i_pp_sign9,
                input  [ 5-1:0] i_Q_frac,

                output [15-1:0] o_aligned_pp1,
                output [15-1:0] o_aligned_pp2,
                output [15-1:0] o_aligned_pp3,
                output [15-1:0] o_aligned_pp4,
                output [15-1:0] o_aligned_pp5,
                output [15-1:0] o_aligned_pp6,
                output [15-1:0] o_aligned_pp7,
                output [15-1:0] o_aligned_pp8,
                output [15-1:0] o_aligned_pp9,
                output [ 6-1:0] o_max_exp,

                output 		    o_valid,
                output [ 5-1:0] o_Q_frac,
                output [50:0] o_transistor_num);

wire [50:0] numbers[9-1:0];

// registers for partial products
reg [4-1:0] pp1_r, pp1_w;
reg [4-1:0] pp2_r, pp2_w;
reg [4-1:0] pp3_r, pp3_w;
reg [4-1:0] pp4_r, pp4_w;
reg [4-1:0] pp5_r, pp5_w;
reg [4-1:0] pp6_r, pp6_w;
reg [4-1:0] pp7_r, pp7_w;
reg [4-1:0] pp8_r, pp8_w;
reg [4-1:0] pp9_r, pp9_w;

// registers for exponents
reg [6-1:0] exp1_r, exp1_w;
reg [6-1:0] exp2_r, exp2_w;
reg [6-1:0] exp3_r, exp3_w;
reg [6-1:0] exp4_r, exp4_w;
reg [6-1:0] exp5_r, exp5_w;
reg [6-1:0] exp6_r, exp6_w;
reg [6-1:0] exp7_r, exp7_w;
reg [6-1:0] exp8_r, exp8_w;
reg [6-1:0] exp9_r, exp9_w;

// register for the maximum exponential term
reg [6-1:0] max_exp_r, max_exp_w;
assign o_max_exp = max_exp_r;

reg valid_r, valid_w;
assign o_valid = valid_r;

reg [5-1:0] Q_frac_reg, Q_frac_w;
assign o_Q_frac = Q_frac_reg;

reg [14-1:0] shifted_unsign_pp_r[0:8], shifted_unsign_pp_w[0:8], pp_sign_r[0:8], pp_sign_w[0:8];

//-- Instantiation
align_CG2_NOclkGating_2 align1(.i_shifted_unsign_pp(shifted_unsign_pp_r[0]),
                             .i_pp_sign(pp_sign_r[0]),
                             .align_pp(o_aligned_pp1),
                             .number(numbers[0]));
align_CG2_NOclkGating_2 align2(.i_shifted_unsign_pp(shifted_unsign_pp_r[1]),
                             .i_pp_sign(pp_sign_r[1]),
                             .align_pp(o_aligned_pp2),
                             .number(numbers[1]));
align_CG2_NOclkGating_2 align3(.i_shifted_unsign_pp(shifted_unsign_pp_r[2]),
                             .i_pp_sign(pp_sign_r[2]),
                             .align_pp(o_aligned_pp3),
                             .number(numbers[2]));
align_CG2_NOclkGating_2 align4(.i_shifted_unsign_pp(shifted_unsign_pp_r[3]),
                             .i_pp_sign(pp_sign_r[3]),
                             .align_pp(o_aligned_pp4),
                             .number(numbers[3]));
align_CG2_NOclkGating_2 align5(.i_shifted_unsign_pp(shifted_unsign_pp_r[4]),
                             .i_pp_sign(pp_sign_r[4]),
                             .align_pp(o_aligned_pp5),
                             .number(numbers[4]));
align_CG2_NOclkGating_2 align6(.i_shifted_unsign_pp(shifted_unsign_pp_r[5]),
                             .i_pp_sign(pp_sign_r[5]),
                             .align_pp(o_aligned_pp6),
                             .number(numbers[5]));
align_CG2_NOclkGating_2 align7(.i_shifted_unsign_pp(shifted_unsign_pp_r[6]),
                             .i_pp_sign(pp_sign_r[6]),
                             .align_pp(o_aligned_pp7),
                             .number(numbers[6]));
align_CG2_NOclkGating_2 align8(.i_shifted_unsign_pp(shifted_unsign_pp_r[7]),
                             .i_pp_sign(pp_sign_r[7]),
                             .align_pp(o_aligned_pp8),
                             .number(numbers[7]));
align_CG2_NOclkGating_2 align9(.i_shifted_unsign_pp(shifted_unsign_pp_r[8]),
                             .i_pp_sign(pp_sign_r[8]),
                             .align_pp(o_aligned_pp9),
                             .number(numbers[8]));

always@(*) begin
    //Need to be changed to multiplexers, but every stage does have these things, the delay can be cancelled
    if (i_inhibit) begin
        valid_w = valid_r;
        max_exp_w = max_exp_r;
        Q_frac_w = Q_frac_reg;
        shifted_unsign_pp_w[0] = shifted_unsign_pp_r[0];
        shifted_unsign_pp_w[1] = shifted_unsign_pp_r[1];
        shifted_unsign_pp_w[2] = shifted_unsign_pp_r[2];
        shifted_unsign_pp_w[3] = shifted_unsign_pp_r[3];
        shifted_unsign_pp_w[4] = shifted_unsign_pp_r[4];
        shifted_unsign_pp_w[5] = shifted_unsign_pp_r[5];
        shifted_unsign_pp_w[6] = shifted_unsign_pp_r[6];
        shifted_unsign_pp_w[7] = shifted_unsign_pp_r[7];
        shifted_unsign_pp_w[8] = shifted_unsign_pp_r[8];
        pp_sign_w[0] = pp_sign_r[0];
        pp_sign_w[1] = pp_sign_r[1];
        pp_sign_w[2] = pp_sign_r[2];
        pp_sign_w[3] = pp_sign_r[3];
        pp_sign_w[4] = pp_sign_r[4];
        pp_sign_w[5] = pp_sign_r[5];
        pp_sign_w[6] = pp_sign_r[6];
        pp_sign_w[7] = pp_sign_r[7];
        pp_sign_w[8] = pp_sign_r[8];
    end
    else begin
        valid_w = i_valid;
        max_exp_w = i_max_exp;
        Q_frac_w = i_Q_frac;
        shifted_unsign_pp_w[0] = i_shifted_unsign_pp1;
        shifted_unsign_pp_w[1] = i_shifted_unsign_pp2;
        shifted_unsign_pp_w[2] = i_shifted_unsign_pp3;
        shifted_unsign_pp_w[3] = i_shifted_unsign_pp4;
        shifted_unsign_pp_w[4] = i_shifted_unsign_pp5;
        shifted_unsign_pp_w[5] = i_shifted_unsign_pp6;
        shifted_unsign_pp_w[6] = i_shifted_unsign_pp7;
        shifted_unsign_pp_w[7] = i_shifted_unsign_pp8;
        shifted_unsign_pp_w[8] = i_shifted_unsign_pp9;
        pp_sign_w[0] = i_pp_sign1;
        pp_sign_w[1] = i_pp_sign2;
        pp_sign_w[2] = i_pp_sign3;
        pp_sign_w[3] = i_pp_sign4;
        pp_sign_w[4] = i_pp_sign5;
        pp_sign_w[5] = i_pp_sign6;
        pp_sign_w[6] = i_pp_sign7;
        pp_sign_w[7] = i_pp_sign8;
        pp_sign_w[8] = i_pp_sign9;
    end
end

always@(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        valid_r <= 0;
        max_exp_r <= 0;
        Q_frac_reg <= 0;
        shifted_unsign_pp_r[0] <= 0;
        shifted_unsign_pp_r[1] <= 0;
        shifted_unsign_pp_r[2] <= 0;
        shifted_unsign_pp_r[3] <= 0;
        shifted_unsign_pp_r[4] <= 0;
        shifted_unsign_pp_r[5] <= 0;
        shifted_unsign_pp_r[6] <= 0;
        shifted_unsign_pp_r[7] <= 0;
        shifted_unsign_pp_r[8] <= 0;
        pp_sign_r[0] <= 0;
        pp_sign_r[1] <= 0;
        pp_sign_r[2] <= 0;
        pp_sign_r[3] <= 0;
        pp_sign_r[4] <= 0;
        pp_sign_r[5] <= 0;
        pp_sign_r[6] <= 0;
        pp_sign_r[7] <= 0;
        pp_sign_r[8] <= 0;
    end
    else begin
        valid_r <= valid_w;
        max_exp_r <= max_exp_w;
        Q_frac_reg <= Q_frac_w;
        shifted_unsign_pp_r[0] <= shifted_unsign_pp_w[0];
        shifted_unsign_pp_r[1] <= shifted_unsign_pp_w[1];
        shifted_unsign_pp_r[2] <= shifted_unsign_pp_w[2];
        shifted_unsign_pp_r[3] <= shifted_unsign_pp_w[3];
        shifted_unsign_pp_r[4] <= shifted_unsign_pp_w[4];
        shifted_unsign_pp_r[5] <= shifted_unsign_pp_w[5];
        shifted_unsign_pp_r[6] <= shifted_unsign_pp_w[6];
        shifted_unsign_pp_r[7] <= shifted_unsign_pp_w[7];
        shifted_unsign_pp_r[8] <= shifted_unsign_pp_w[8];
        pp_sign_r[0] <= pp_sign_w[0];
        pp_sign_r[1] <= pp_sign_w[1];
        pp_sign_r[2] <= pp_sign_w[2];
        pp_sign_r[3] <= pp_sign_w[3];
        pp_sign_r[4] <= pp_sign_w[4];
        pp_sign_r[5] <= pp_sign_w[5];
        pp_sign_r[6] <= pp_sign_w[6];
        pp_sign_r[7] <= pp_sign_w[7];
        pp_sign_r[8] <= pp_sign_w[8];
    end
end

reg [50:0] sum;
integer j;
always @(*) begin
    sum = 0;
    for (j=0; j<9; j=j+1) begin 
        sum = sum + numbers[j];
    end
end

assign o_transistor_num = sum;
endmodule
