/**************************************************************************************************
*    File Name:  mac_stg5.v
*      Version:  2.0.0
*      Arthors:  Lin, Juang, Kung
*
*  Dependecies:  
*
*  Description:  MAC stage 5
*
*      Details:          
*               
* Rev     Arthor   Date          Changes
* ---------------------------------------------------------------------------------------
* older   Lin      ----/--/--    ---
* 1.0.0   Juang    2018/05/05    remove bias on norm exp 
* 1.0.1   Kung     2019/02/26    Modify Datapath to 16-bit
*                                Modify the port width of i_norm_sum from 23 to 10
* 2.0.0   Hsieh    2020/11/02    Change to 4-bit FloatSD4 weight
**************************************************************************************************/

module mac_stg5(input           i_clk,
                input           i_rst_n,
                input           i_inhibit,
                input           i_valid,
                input  [ 6-1:0] i_max_exp,
                input  [11-1:0] i_norm_sum,
                input  [ 5-1:0] i_exp_diff,
                input           i_exp_carry,
                input           i_sgn,
                input  [ 5-1:0] i_Q_frac,

                output          o_valid,
                output [16-1:0] o_conv,
                output [50:0]   o_transistor_num);

reg          valid_r, valid_w;
reg [11-1:0] norm_sum_r, norm_sum_w;
reg [ 5-1:0] exp_diff_r, exp_diff_w;
reg          exp_carry_r, exp_carry_w;
reg          sgn_r, sgn_w;
reg [ 6-1:0] max_exp_r, max_exp_w;
reg [ 5-1:0] Q_frac_reg;

wire [50:0] numbers;

assign o_valid = valid_r;

exp_Handle_norm F2(.norm_sum_with_leading1(norm_sum_r),
                   .signed_exp_diff(exp_diff_r),
                   .exp_carry(exp_carry_r),
                   .sign(sgn_r),
                   .max_exp(max_exp_r),
                   .Q_frac(Q_frac_reg),
                   
                   .MAC_output(o_conv),
                   .number(numbers));

always@(*) begin
    if (i_inhibit) begin
        valid_w     = valid_r    ;
        norm_sum_w  = norm_sum_r ;
        exp_diff_w  = exp_diff_r ;
        exp_carry_w = exp_carry_r;
        sgn_w       = sgn_r      ;
        max_exp_w   = max_exp_r  ;
    end
    else begin
        valid_w     = i_valid    ;
        norm_sum_w  = i_norm_sum ;
        exp_diff_w  = i_exp_diff ;
        exp_carry_w = i_exp_carry;
        sgn_w       = i_sgn      ;
        max_exp_w   = i_max_exp  ;
    end
end

always@(posedge i_clk  or negedge i_rst_n) begin
    if (~i_rst_n) begin
        valid_r    <= 0;
        norm_sum_r <= 0;
        exp_diff_r <= 0;
        sgn_r      <= 0;
        sgn_r      <= 0;
        max_exp_r  <= 0;
        Q_frac_reg <= 0;
    end
    else begin
        valid_r     <= valid_w    ;
        norm_sum_r  <= norm_sum_w ;
        exp_diff_r  <= exp_diff_w ;
        exp_carry_r <= exp_carry_w;
        sgn_r       <= sgn_w      ;
        max_exp_r   <= max_exp_w  ;
        Q_frac_reg  <= i_Q_frac   ;
    end
end

// reg [50:0] num;
// integer j;
// always @(*) begin
//     num = 0;
//     for (j=0; j<0; j=j+1) begin 
//         num = num + numbers[j];
//     end
// end

//Doesn't count _w
assign o_transistor_num = numbers + 46 * 27;

endmodule
