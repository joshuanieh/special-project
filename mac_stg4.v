/**************************************************************************************************
*    File Name:  mac_stg4.v
*      Version:  2.0.0
*      Arthors:  Lin, Juang, Kung
*
*  Dependecies:  
*
*  Description:  MAC stage 4
*
*      Details:          
*               
* Rev     Arthor   Date          Changes
* ---------------------------------------------------------------------------------------
* 1.0.0   Juang    2018/05/05    remove bias on norm exp 
* 1.0.1   Kung     2019/02/26    Modify Datapath to 16-bit
*                                Modify the port width of i_norm_sum from 23 to 10
*								 Modify the port width of i_psum to 16			
* 2.0.0   Hsieh    2020/11/02    Change to 4-bit FloatSD4 weight
**************************************************************************************************/
// `include "./MAC_top/MAC_subsystem/final_norm_noSUB.v"

module mac_stg4(input 		    i_clk,
                input 		    i_rst_n,
                input 		    i_valid,
                input 		    i_inhibit,
                input  [19-1:0] i_psum,
                input  [ 6-1:0] i_max_exp,

                output [ 6-1:0] o_max_exp,
                output 		    o_valid,
                output [11-1:0] o_norm_sum,
                output [ 5-1:0] o_exp_diff,
                output          o_exp_carry,
                output 		    o_sgn,

                input  [ 5-1:0] i_Q_frac,
                output [ 5-1:0] o_Q_frac);

reg          valid_r, valid_w;
reg [19-1:0] psum_r, psum_w;
reg [ 6-1:0] max_exp_r, max_exp_w;

assign o_valid = valid_r;

// bypass Max. Exp.
assign o_max_exp = max_exp_r;

reg [5-1:0] Q_frac_reg;
assign o_Q_frac = Q_frac_reg;
final_norm_noSUB F1(.sum(psum_r),
                    .final_norm_sum_with_leading1(o_norm_sum),
                    .signed_exp_diff(o_exp_diff),
                    .exp_carry(o_exp_carry),
                    .sign(o_sgn));

always@(*) begin
    if (i_inhibit) begin
        valid_w = valid_r;
        psum_w = psum_r;
        max_exp_w = max_exp_r;
    end
    else begin
        valid_w = i_valid;
        psum_w = i_psum;
        max_exp_w = i_max_exp;
    end
end

always@(posedge i_clk  or negedge i_rst_n) begin
    if (~i_rst_n) begin
        valid_r <= 0;
        psum_r <= 0;
        max_exp_r <= 0;
        Q_frac_reg <= 0;
    end
    else begin
        valid_r <= valid_w;
        psum_r <= psum_w;
        max_exp_r <= max_exp_w;
        Q_frac_reg <= i_Q_frac;
    end
end

endmodule
