/**************************************************************************************************
*    File Name:  mac.v
*      Version:  6.0.0
*      Arthors:  Lin, Juang, Kung
*
*  Dependecies:  mac_stg1.v
*                mac_stg2.v
*                mac_stg3.v
*                mac_stg4.v
*                mac_stg5.v
*
*  Description:  Multiplication-Accumulator Array for Two 9-word Vectors
*
*      Details:  - i_im vectors  --> 1+4-bit mantissa, 3-bit exp
*                - i_ker vectors --> 4-bit
*                - Q_frac        --> weight offset (5-bit, range 0~31), start from MSB
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
* 5.1.2   Sun      2019/05/28    Change it into new decoder and add comments.                 
* 6.0.0   Hsieh    2020/11/02    Change to 4-bit FloatSD4 weight
**************************************************************************************************/

module mac       (input               clk,
                  input               i_rst_n,
                  input               i_inhibit,
                  input               i_valid,
                  input      [ 9-1:0] i_q,	// Need to handle at last, we now use the difference and pipeline to the last stage...
                  input      [ 9-1:0] zero_vector,
                  
                  input      [ 8-1:0] i_im1,
                  input      [ 8-1:0] i_im2,
                  input      [ 8-1:0] i_im3,
                  input      [ 8-1:0] i_im4,
                  input      [ 8-1:0] i_im5,
                  input      [ 8-1:0] i_im6,
                  input      [ 8-1:0] i_im7,
                  input      [ 8-1:0] i_im8,
                  input      [ 8-1:0] i_im9,

                  input      [ 4-1:0] i_ker1,
                  input      [ 4-1:0] i_ker2,
                  input      [ 4-1:0] i_ker3,
                  input      [ 4-1:0] i_ker4,
                  input      [ 4-1:0] i_ker5,
                  input      [ 4-1:0] i_ker6,
                  input      [ 4-1:0] i_ker7,
                  input      [ 4-1:0] i_ker8,
                  input      [ 4-1:0] i_ker9,

                  output reg 		  o_valid,
                  output     [16-1:0] o_conv,
                  output     [50:0]   o_transistor_num);

// partial products
wire [4-1:0] stg1_pp1;
wire [4-1:0] stg1_pp2;
wire [4-1:0] stg1_pp3;
wire [4-1:0] stg1_pp4;
wire [4-1:0] stg1_pp5;
wire [4-1:0] stg1_pp6;
wire [4-1:0] stg1_pp7;
wire [4-1:0] stg1_pp8;
wire [4-1:0] stg1_pp9;

wire [5-1:0] Q_frac;
assign Q_frac = i_q[4:0];

// exponentials
wire [6-1:0] stg1_exp1;
wire [6-1:0] stg1_exp2;
wire [6-1:0] stg1_exp3;
wire [6-1:0] stg1_exp4;
wire [6-1:0] stg1_exp5;
wire [6-1:0] stg1_exp6;
wire [6-1:0] stg1_exp7;
wire [6-1:0] stg1_exp8;
wire [6-1:0] stg1_exp9;

// maximum exponenti
wire [6-1:0] stg1_max_exp;
wire [5-1:0] o_Q_frac_stg1, o_Q_frac_stg2, o_Q_frac_stg3, o_Q_frac_stg4;

// flags
wire 	   stg1_valid;

// aligned partial products
wire [15-1:0] stg2_app1;
wire [15-1:0] stg2_app2;
wire [15-1:0] stg2_app3;
wire [15-1:0] stg2_app4;
wire [15-1:0] stg2_app5;
wire [15-1:0] stg2_app6;
wire [15-1:0] stg2_app7;
wire [15-1:0] stg2_app8;
wire [15-1:0] stg2_app9;
wire [ 6-1:0] stg2_max_exp;
wire 	        stg2_valid;

wire [19-1:0] stg3_psum;
wire 		      stg3_valid;
wire [ 6-1:0] stg3_max_exp;

wire [ 6-1:0] stg4_max_exp;
wire		      stg4_valid;
wire [11-1:0] stg4_norm_sum;
wire [ 6-1:0] stg4_exp_diff;
wire          stg4_exp_carry;
wire 		      stg4_sgn;

wire          stg5_o_valid;
wire [16-1:0] stg5_o_conv;
wire          o_valid_in;

reg  [16-1:0] conv_r;
wire [16-1:0] conv_w;

wire [50:0]   number[9-1:0];
//-- <MK Sun Adding some new flag to indicate>
// wire o_update_mode_stg1, o_update_mode_stg2, o_update_mode_stg3, o_update_mode_stg4;

// MUX21H g(Z,A,B,CTRL,number)

// assign o_valid_in = (i_inhibit) ? 1'b0 : stg5_o_valid;
MX#(1) g_1(o_valid_in, stg5_o_valid, 1'b0, i_inhibit, number[0]);
assign o_conv = conv_r;
wire and_result;
wire inv_result;
IV inv1(inv_result, o_valid_in, number[7]);
AN2 and1(and_result, i_inhibit, inv_result, number[8]);
// assign conv_w = (i_inhibit && ~o_valid_in) ? 16'd0 : stg5_o_conv;
MX#(16) g_2(conv_w, stg5_o_conv, 16'd0, and_result, number[1]);

mac_stg1 stg1(.i_clk(clk),
              .i_rst_n(i_rst_n),
              .i_valid(i_valid),
              .i_inhibit(i_inhibit),
              .Q_frac(Q_frac),
              .skip(zero_vector),
              .i_im1(i_im1),
              .i_im2(i_im2),
              .i_im3(i_im3),
              .i_im4(i_im4),
              .i_im5(i_im5),
              .i_im6(i_im6),
              .i_im7(i_im7),
              .i_im8(i_im8),
              .i_im9(i_im9),
              .i_ker1(i_ker1),
              .i_ker2(i_ker2),
              .i_ker3(i_ker3),
              .i_ker4(i_ker4),
              .i_ker5(i_ker5),
              .i_ker6(i_ker6),
              .i_ker7(i_ker7),
              .i_ker8(i_ker8),
              .i_ker9(i_ker9),

              .o_denorm_pp1(stg1_pp1),
              .o_denorm_pp2(stg1_pp2),
              .o_denorm_pp3(stg1_pp3),
              .o_denorm_pp4(stg1_pp4),
              .o_denorm_pp5(stg1_pp5),
              .o_denorm_pp6(stg1_pp6),
              .o_denorm_pp7(stg1_pp7),
              .o_denorm_pp8(stg1_pp8),
              .o_denorm_pp9(stg1_pp9),

              .o_exp1(stg1_exp1),
              .o_exp2(stg1_exp2),
              .o_exp3(stg1_exp3),
              .o_exp4(stg1_exp4),
              .o_exp5(stg1_exp5),
              .o_exp6(stg1_exp6),
              .o_exp7(stg1_exp7),
              .o_exp8(stg1_exp8),
              .o_exp9(stg1_exp9),
              .o_max_exp(stg1_max_exp),
              .o_valid(stg1_valid),
              .o_Q_frac(o_Q_frac_stg1)
            //   .o_transistor_num(number[2])
              );

mac_stg2 stg2(.i_clk(clk),
              .i_rst_n(i_rst_n),
              .i_valid(stg1_valid),
              .i_inhibit(i_inhibit),

              .i_pp1(stg1_pp1),
              .i_pp2(stg1_pp2),
              .i_pp3(stg1_pp3),
              .i_pp4(stg1_pp4),
              .i_pp5(stg1_pp5),
              .i_pp6(stg1_pp6),
              .i_pp7(stg1_pp7),
              .i_pp8(stg1_pp8),
              .i_pp9(stg1_pp9),

              .i_exp1(stg1_exp1),
              .i_exp2(stg1_exp2),
              .i_exp3(stg1_exp3),
              .i_exp4(stg1_exp4),
              .i_exp5(stg1_exp5),
              .i_exp6(stg1_exp6),
              .i_exp7(stg1_exp7),
              .i_exp8(stg1_exp8),
              .i_exp9(stg1_exp9),

              .i_max_exp(stg1_max_exp),

              .o_aligned_pp1(stg2_app1),
              .o_aligned_pp2(stg2_app2),
              .o_aligned_pp3(stg2_app3),
              .o_aligned_pp4(stg2_app4),
              .o_aligned_pp5(stg2_app5),
              .o_aligned_pp6(stg2_app6),
              .o_aligned_pp7(stg2_app7),
              .o_aligned_pp8(stg2_app8),
              .o_aligned_pp9(stg2_app9),
              .o_max_exp(stg2_max_exp),

              .o_valid(stg2_valid),
              .i_Q_frac(o_Q_frac_stg1),
              .o_Q_frac(o_Q_frac_stg2),
              .o_transistor_num(number[3])
              );

mac_stg3 stg3(.i_clk(clk),
              .i_rst_n(i_rst_n),
              .i_valid(stg2_valid),
              .i_inhibit(i_inhibit),

              .i_aligned_pp1(stg2_app1),
              .i_aligned_pp2(stg2_app2),
              .i_aligned_pp3(stg2_app3),
              .i_aligned_pp4(stg2_app4),
              .i_aligned_pp5(stg2_app5),
              .i_aligned_pp6(stg2_app6),
              .i_aligned_pp7(stg2_app7),
              .i_aligned_pp8(stg2_app8),
              .i_aligned_pp9(stg2_app9),
              .i_max_exp(stg2_max_exp),

              .o_psum(stg3_psum),
              .o_valid(stg3_valid),
              .o_max_exp(stg3_max_exp),
              .i_Q_frac(o_Q_frac_stg2),
              .o_Q_frac(o_Q_frac_stg3)
            //   .o_transistor_num(number[4])
              );

mac_stg4 stg4(.i_clk     (clk),
              .i_rst_n   (i_rst_n),
              .i_valid   (stg3_valid),
              .i_inhibit (i_inhibit),
              .i_psum    (stg3_psum),
              .i_max_exp (stg3_max_exp),

              .o_max_exp   (stg4_max_exp),
              .o_valid     (stg4_valid),
              .o_norm_sum  (stg4_norm_sum),
              .o_exp_diff  (stg4_exp_diff),
              .o_exp_carry (stg4_exp_carry),
              .o_sgn       (stg4_sgn),

              .i_Q_frac(o_Q_frac_stg3),
              .o_Q_frac(o_Q_frac_stg4)
            //   .o_transistor_num(number[5])
              );

mac_stg5 stg5(.i_clk       (clk),
              .i_rst_n     (i_rst_n),
              .i_inhibit   (i_inhibit),
              .i_valid     (stg4_valid),
              .i_max_exp   (stg4_max_exp),
              .i_norm_sum  (stg4_norm_sum),
              .i_exp_diff  (stg4_exp_diff),
              .i_exp_carry (stg4_exp_carry),
              .i_sgn       (stg4_sgn),
              .i_Q_frac    (o_Q_frac_stg4),

              .o_valid(stg5_o_valid),
              .o_conv(stg5_o_conv)
            //   .o_transistor_num(number[6])
              );

integer l_p = 0;
integer out_batch;

initial begin
    out_batch = $fopen("120_each_stage_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/0_120_2_1_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/1_120_2_1_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/2_120_2_1_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/3_120_2_1_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/4_120_2_1_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/5_120_2_1_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/6_120_2_1_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/7_120_2_1_output.txt", "w");
    $fclose(out_batch);
    out_batch = $fopen("MAC_subsystem/m2_1/8_120_2_1_output.txt", "w");
    $fclose(out_batch);
end

always @(posedge clk) begin
    //-- file open for the case we are going to print out the message to text.
    if(i_valid) begin
        out_batch = $fopen("120_each_stage_output.txt", "a");

        $fwrite(out_batch, "\nStage 1\n");
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp1);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp2);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp3);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp4);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp5);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp6);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp7);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp8);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_pp9);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp1);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp2);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp3);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp4);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp5);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp6);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp7);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp8);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_exp9);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_max_exp);
        $fwrite(out_batch, "Stage 1: %06X\n", stg1_valid);
        $fwrite(out_batch, "Stage 1: %06X\n", o_Q_frac_stg1);

        $fwrite(out_batch, "\nStage 2-2\n");
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app1);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app2);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app3);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app4);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app5);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app6);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app7);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app8);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_app9);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_max_exp);
        $fwrite(out_batch, "Stage 2-2: %06X\n", stg2_valid);
        $fwrite(out_batch, "Stage 2-2: %06X\n", o_Q_frac_stg2);
        
        $fwrite(out_batch, "Stage 3: %06X\n", stg3_psum);
        $fwrite(out_batch, "Stage 3: %06X\n", stg3_valid);
        $fwrite(out_batch, "Stage 3: %06X\n", stg3_max_exp);
        $fwrite(out_batch, "Stage 3: %06X\n", o_Q_frac_stg3);
        
        $fwrite(out_batch, "\nStage 4\n");
        $fwrite(out_batch, "Stage 4: %06X\n", stg4_max_exp);
        $fwrite(out_batch, "Stage 4: %06X\n", stg4_valid);
        $fwrite(out_batch, "Stage 4: %06X\n", stg4_norm_sum);
        $fwrite(out_batch, "Stage 4: %06X\n", stg4_exp_diff);
        $fwrite(out_batch, "Stage 4: %06X\n", stg4_exp_carry);
        $fwrite(out_batch, "Stage 4: %06X\n", stg4_sgn);
        $fwrite(out_batch, "Stage 4: %06X\n", o_Q_frac_stg4);
        
        $fwrite(out_batch, "\nStage 5\n");
        $fwrite(out_batch, "Stage 5: %06X\n", stg5_o_valid);
        $fwrite(out_batch, "Stage 5: %06X\n", stg5_o_conv);

        $fclose(out_batch);
    end
end
assign number[2] = 0;
assign number[4] = 0;
assign number[5] = 0;
assign number[6] = 0;
reg [50:0] sum;
integer j;
always @(*) begin
    sum = 0;
    for (j=0; j<9; j=j+1) begin 
        sum = sum + number[j];
    end
end
assign o_transistor_num = sum;

always @(posedge clk) begin
    conv_r <= conv_w;
    o_valid <= o_valid_in;
end

endmodule
