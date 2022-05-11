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
module mac_stg2_1(input           i_clk,
                input           i_rst_n,
                input           i_valid,
                input           i_inhibit,
                input  [ 9-1:0] i_skip,
                input  [ 4-1:0] i_pp1,
                input  [ 4-1:0] i_pp2,
                input  [ 4-1:0] i_pp3,
                input  [ 4-1:0] i_pp4,
                input  [ 4-1:0] i_pp5,
                input  [ 4-1:0] i_pp6,
                input  [ 4-1:0] i_pp7,
                input  [ 4-1:0] i_pp8,
                input  [ 4-1:0] i_pp9,

                input  [ 6-1:0] i_exp1,
                input  [ 6-1:0] i_exp2,
                input  [ 6-1:0] i_exp3,
                input  [ 6-1:0] i_exp4,
                input  [ 6-1:0] i_exp5,
                input  [ 6-1:0] i_exp6,
                input  [ 6-1:0] i_exp7,
                input  [ 6-1:0] i_exp8,
                input  [ 6-1:0] i_exp9,

                input  [ 6-1:0] i_max_exp,
                input  [ 5-1:0] i_Q_frac,

                output [14-1:0] o_shifted_unsign_pp1,
                output [14-1:0] o_shifted_unsign_pp2,
                output [14-1:0] o_shifted_unsign_pp3,
                output [14-1:0] o_shifted_unsign_pp4,
                output [14-1:0] o_shifted_unsign_pp5,
                output [14-1:0] o_shifted_unsign_pp6,
                output [14-1:0] o_shifted_unsign_pp7,
                output [14-1:0] o_shifted_unsign_pp8,
                output [14-1:0] o_shifted_unsign_pp9,
                output          o_pp_sign1,
                output          o_pp_sign2,
                output          o_pp_sign3,
                output          o_pp_sign4,
                output          o_pp_sign5,
                output          o_pp_sign6,
                output          o_pp_sign7,
                output          o_pp_sign8,
                output          o_pp_sign9,

                output [ 6-1:0] o_max_exp,

                output 		    o_valid,
                output [ 5-1:0] o_Q_frac,
                output [50:0] o_transistor_num);

wire [50:0] numbers[10-1:0];
reg valid_r, valid_w;
reg [9-1:0] skip_r, skip_w;

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
assign o_valid = valid_r;

reg [5-1:0] Q_frac_reg;
assign o_Q_frac = Q_frac_reg;

//-- Instantiation
max_exp_determ max_exp1(.skip(skip_r),
                        .exp1(i_exp1),
                        .exp2(i_exp2),
                        .exp3(i_exp3),
                        .exp4(i_exp4),
                        .exp5(i_exp5),
                        .exp6(i_exp6),
                        .exp7(i_exp7),
                        .exp8(i_exp8),
                        .exp9(i_exp9),
                        .max_exp(o_max_exp),
                        .number(numbers[9]) );

align_CG2_NOclkGating_1 align1(.denorm_pp(pp1_r),
                             .exp(exp1_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp1),
                             .pp_sign(o_pp_sign1),
                             .number(numbers[0]));
align_CG2_NOclkGating_1 align2(.denorm_pp(pp2_r),
                             .exp(exp2_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp2),
                             .pp_sign(o_pp_sign2),
                             .number(numbers[1]));
align_CG2_NOclkGating_1 align3(.denorm_pp(pp3_r),
                             .exp(exp3_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp3),
                             .pp_sign(o_pp_sign3),
                             .number(numbers[2]));
align_CG2_NOclkGating_1 align4(.denorm_pp(pp4_r),
                             .exp(exp4_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp4),
                             .pp_sign(o_pp_sign4),
                             .number(numbers[3]));
align_CG2_NOclkGating_1 align5(.denorm_pp(pp5_r),
                             .exp(exp5_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp5),
                             .pp_sign(o_pp_sign5),
                             .number(numbers[4]));
align_CG2_NOclkGating_1 align6(.denorm_pp(pp6_r),
                             .exp(exp6_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp6),
                             .pp_sign(o_pp_sign6),
                             .number(numbers[5]));
align_CG2_NOclkGating_1 align7(.denorm_pp(pp7_r),
                             .exp(exp7_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp7),
                             .pp_sign(o_pp_sign7),
                             .number(numbers[6]));
align_CG2_NOclkGating_1 align8(.denorm_pp(pp8_r),
                             .exp(exp8_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp8),
                             .pp_sign(o_pp_sign8),
                             .number(numbers[7]));
align_CG2_NOclkGating_1 align9(.denorm_pp(pp9_r),
                             .exp(exp9_r),
                             .max_exp(max_exp_r),
                             .shifted_unsign_pp(o_shifted_unsign_pp9),
                             .pp_sign(o_pp_sign9),
                             .number(numbers[8]));

always@(*) begin
    //Need to be changed to multiplexers, but every stage does have these things, the delay can be cancelled
    if (i_inhibit) begin
        valid_w = valid_r;

        pp1_w = pp1_r;
        pp2_w = pp2_r;
        pp3_w = pp3_r;
        pp4_w = pp4_r;
        pp5_w = pp5_r;
        pp6_w = pp6_r;
        pp7_w = pp7_r;
        pp8_w = pp8_r;
        pp9_w = pp9_r;

        exp1_w = exp1_r;
        exp2_w = exp2_r;
        exp3_w = exp3_r;
        exp4_w = exp4_r;
        exp5_w = exp5_r;
        exp6_w = exp6_r;
        exp7_w = exp7_r;
        exp8_w = exp8_r;
        exp9_w = exp9_r;

        skip_w = skip_r;
    end
    else begin
        valid_w = i_valid;

        pp1_w = i_pp1;
        pp2_w = i_pp2;
        pp3_w = i_pp3;
        pp4_w = i_pp4;
        pp5_w = i_pp5;
        pp6_w = i_pp6;
        pp7_w = i_pp7;
        pp8_w = i_pp8;
        pp9_w = i_pp9;

        exp1_w = i_exp1;
        exp2_w = i_exp2;
        exp3_w = i_exp3;
        exp4_w = i_exp4;
        exp5_w = i_exp5;
        exp6_w = i_exp6;
        exp7_w = i_exp7;
        exp8_w = i_exp8;
        exp9_w = i_exp9;

        skip_w = i_skip;
    end
end

always@(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        valid_r <= 0;

        pp1_r <= 0;
        pp2_r <= 0;
        pp3_r <= 0;
        pp4_r <= 0;
        pp5_r <= 0;
        pp6_r <= 0;
        pp7_r <= 0;
        pp8_r <= 0;
        pp9_r <= 0;

        exp1_r <= 0;
        exp2_r <= 0;
        exp3_r <= 0;
        exp4_r <= 0;
        exp5_r <= 0;
        exp6_r <= 0;
        exp7_r <= 0;
        exp8_r <= 0;
        exp9_r <= 0;

        skip_r <= 0;
        Q_frac_reg <= 0;
    end
    else begin
        valid_r <= valid_w;

        pp1_r <= pp1_w;
        pp2_r <= pp2_w;
        pp3_r <= pp3_w;
        pp4_r <= pp4_w;
        pp5_r <= pp5_w;
        pp6_r <= pp6_w;
        pp7_r <= pp7_w;
        pp8_r <= pp8_w;
        pp9_r <= pp9_w;

        exp1_r <= exp1_w;
        exp2_r <= exp2_w;
        exp3_r <= exp3_w;
        exp4_r <= exp4_w;
        exp5_r <= exp5_w;
        exp6_r <= exp6_w;
        exp7_r <= exp7_w;
        exp8_r <= exp8_w;
        exp9_r <= exp9_w;

        skip_r <= skip_w;
        Q_frac_reg <= i_Q_frac;
    end
end

reg [50:0] sum;
integer j;
always @(*) begin
    sum = 0;
    for (j=0; j<10; j=j+1) begin 
        sum = sum + numbers[j];
    end
end

assign o_transistor_num = sum;
endmodule
