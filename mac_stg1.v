/**************************************************************************************************
*
*    File Name:  mac_stg1.v
*      Version:  2.0.0
*      Arthors:  Lin, Jiang, Juang
*
*  Dependecies:  ./mac_subsystem/pp_generate.v
*
*  Description:  Multiplication-Accumulator Array for Two 9-word Vectors stage 1
*
*      Details:  - i_im vectors  --> 1+4-bit mantissa, 5-bit exp (range -26 ~ +5).
*                - i_ker vectors --> 6-bit mantissa (2 groups), 1+2-bit exp.
*                - update_mode   --> use gradient as weight, need to realign gradient.
*                - Q_frac        --> float dot offset (4-bit, range 0~15), actual offset will be
*									 Q_frac+24 from mantissa LSB
*               
* Rev     Arthor   Date          Changes
* ---------------------------------------------------------------------------------------
* older   Lin      ----/--/--    ---
* 0.9.1   Jiang    ----/--/--    ---
* 1.0.0   Juang    2018/04/28    Changed i_im inputs to 10-bit format.
*                                Changed i_ker inputs to 10-bit format.
*                                Added update mode to realign gradient
* 1.0.1   Juang    2018/05/05    Changed i_ker inputs to 9-bit format. 
* 1.0.2   Juang    2018/06/03    Added skip back.                                 
*                                Changed i_im to 9-bit.
* 1.1.0   Juang    2018/06/23    Change to 8-bit
*                                Remove Q-frac in this stage
* 2.0.0   Hsieh    2020/11/02    Change to 4-bit FloatSD4 weight
**************************************************************************************************/
module mac_stg1(input          i_clk,
                input          i_rst_n,
                input          i_valid,
                input          i_inhibit,
                input  [5-1:0] Q_frac,
                input  [9-1:0] skip,     // is it zero skipping part...
                input  [8-1:0] i_im1,
                input  [8-1:0] i_im2,
                input  [8-1:0] i_im3,
                input  [8-1:0] i_im4,
                input  [8-1:0] i_im5,
                input  [8-1:0] i_im6,
                input  [8-1:0] i_im7,
                input  [8-1:0] i_im8,
                input  [8-1:0] i_im9,

                input  [4-1:0] i_ker1,
                input  [4-1:0] i_ker2,
                input  [4-1:0] i_ker3,
                input  [4-1:0] i_ker4,
                input  [4-1:0] i_ker5,
                input  [4-1:0] i_ker6,
                input  [4-1:0] i_ker7,
                input  [4-1:0] i_ker8,
                input  [4-1:0] i_ker9,

                output [4-1:0] o_denorm_pp1,
                output [4-1:0] o_denorm_pp2,
                output [4-1:0] o_denorm_pp3,
                output [4-1:0] o_denorm_pp4,
                output [4-1:0] o_denorm_pp5,
                output [4-1:0] o_denorm_pp6,
                output [4-1:0] o_denorm_pp7,
                output [4-1:0] o_denorm_pp8,
                output [4-1:0] o_denorm_pp9,

                output [6-1:0] o_exp1,    // <MK Sun, change from 9 bits to 6 bits.>
                output [6-1:0] o_exp2,    // <MK Sun, change from 9 bits to 6 bits.>
                output [6-1:0] o_exp3,    // <MK Sun, change from 9 bits to 6 bits.>
                output [6-1:0] o_exp4,    // <MK Sun, change from 9 bits to 6 bits.>
                output [6-1:0] o_exp5,    // <MK Sun, change from 9 bits to 6 bits.>
                output [6-1:0] o_exp6,    // <MK Sun, change from 9 bits to 6 bits.>
                output [6-1:0] o_exp7,    // <MK Sun, change from 9 bits to 6 bits.>
                output [6-1:0] o_exp8,    // <MK Sun, change from 9 bits to 6 bits.>
                output [6-1:0] o_exp9,    // <MK Sun, change from 9 bits to 6 bits.>

                output [6-1:0] o_max_exp, // <MK Sun, change from 9 bits to 6 bits.>
                output 		   o_valid,
                output [5-1:0] o_Q_frac,
                output [50:0]  o_transistor_num);

reg valid_r, valid_w;

reg [5-1:0] Q_frac_reg;

reg [8-1:0] im1_r, im1_w;
reg [8-1:0] im2_r, im2_w;
reg [8-1:0] im3_r, im3_w;
reg [8-1:0] im4_r, im4_w;
reg [8-1:0] im5_r, im5_w;
reg [8-1:0] im6_r, im6_w;
reg [8-1:0] im7_r, im7_w;
reg [8-1:0] im8_r, im8_w;
reg [8-1:0] im9_r, im9_w;

reg [4-1:0] ker1_r, ker1_w;
reg [4-1:0] ker2_r, ker2_w;
reg [4-1:0] ker3_r, ker3_w;
reg [4-1:0] ker4_r, ker4_w;
reg [4-1:0] ker5_r, ker5_w;
reg [4-1:0] ker6_r, ker6_w;
reg [4-1:0] ker7_r, ker7_w;
reg [4-1:0] ker8_r, ker8_w;
reg [4-1:0] ker9_r, ker9_w;

reg [9-1:0] skip_r;

wire [50:0] numbers [0:10];

assign o_valid = valid_r;
assign o_Q_frac = Q_frac_reg;

// instantiation
PPgenerator pp_gen1(.image(im1_r),
                    .weight(ker1_r),
                    .denorm_pp(o_denorm_pp1),
                    .exp(o_exp1),
                    .number(numbers[0]) );
PPgenerator pp_gen2(.image(im2_r),
                    .weight(ker2_r),
                    .denorm_pp(o_denorm_pp2),
                    .exp(o_exp2),
                    .number(numbers[1]) );
PPgenerator pp_gen3(.image(im3_r),
                    .weight(ker3_r),
                    .denorm_pp(o_denorm_pp3),
                    .exp(o_exp3),
                    .number(numbers[2]) );
PPgenerator pp_gen4(.image(im4_r),
                    .weight(ker4_r),
                    .denorm_pp(o_denorm_pp4),
                    .exp(o_exp4),
                    .number(numbers[3]) );
PPgenerator pp_gen5(.image(im5_r),
                    .weight(ker5_r),
                    .denorm_pp(o_denorm_pp5),
                    .exp(o_exp5),
                    .number(numbers[4]) );
PPgenerator pp_gen6(.image(im6_r),
                    .weight(ker6_r),
                    .denorm_pp(o_denorm_pp6),
                    .exp(o_exp6),
                    .number(numbers[5]) );
PPgenerator pp_gen7(.image(im7_r),
                    .weight(ker7_r),
                    .denorm_pp(o_denorm_pp7),
                    .exp(o_exp7),
                    .number(numbers[6]) );
PPgenerator pp_gen8(.image(im8_r),
                    .weight(ker8_r),
                    .denorm_pp(o_denorm_pp8),
                    .exp(o_exp8),
                    .number(numbers[7]) );
PPgenerator pp_gen9(.image(im9_r),
                    .weight(ker9_r),
                    .denorm_pp(o_denorm_pp9),
                    .exp(o_exp9),
                    .number(numbers[8]) );

max_exp_determ max_exp1(.skip(skip_r),
                        .exp1(o_exp1),
                        .exp2(o_exp2),
                        .exp3(o_exp3),
                        .exp4(o_exp4),
                        .exp5(o_exp5),
                        .exp6(o_exp6),
                        .exp7(o_exp7),
                        .exp8(o_exp8),
                        .exp9(o_exp9),
                        .max_exp(o_max_exp),
                        .number(numbers[9]) );

always@(*) begin
    if (i_inhibit) begin
        valid_w = valid_r;
        im1_w = im1_r;
        im2_w = im2_r;
        im3_w = im3_r;
        im4_w = im4_r;
        im5_w = im5_r;
        im6_w = im6_r;
        im7_w = im7_r;
        im8_w = im8_r;
        im9_w = im9_r;
        ker1_w = ker1_r;
        ker2_w = ker2_r;
        ker3_w = ker3_r;
        ker4_w = ker4_r;
        ker5_w = ker5_r;
        ker6_w = ker6_r;
        ker7_w = ker7_r;
        ker8_w = ker8_r;
        ker9_w = ker9_r;
    end
    else begin
        valid_w = i_valid;
        im1_w = i_im1;
        im2_w = i_im2;
        im3_w = i_im3;
        im4_w = i_im4;
        im5_w = i_im5;
        im6_w = i_im6;
        im7_w = i_im7;
        im8_w = i_im8;
        im9_w = i_im9;
        ker1_w = i_ker1;
        ker2_w = i_ker2;
        ker3_w = i_ker3;
        ker4_w = i_ker4;
        ker5_w = i_ker5;
        ker6_w = i_ker6;
        ker7_w = i_ker7;
        ker8_w = i_ker8;
        ker9_w = i_ker9;
    end
end

always@(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        valid_r    <=  1'b0;
        im1_r      <=  8'd0;
        im2_r      <=  8'd0;
        im3_r      <=  8'd0;
        im4_r      <=  8'd0;
        im5_r      <=  8'd0;
        im6_r      <=  8'd0;
        im7_r      <=  8'd0;
        im8_r      <=  8'd0;
        im9_r      <=  8'd0;
        ker1_r     <=  8'd0;
        ker2_r     <=  8'd0;
        ker3_r     <=  8'd0;
        ker4_r     <=  8'd0;
        ker5_r     <=  8'd0;
        ker6_r     <=  8'd0;
        ker7_r     <=  8'd0;
        ker8_r     <=  8'd0;
        ker9_r     <=  8'd0;
        skip_r     <=  9'd0;

        Q_frac_reg <=  4'd0;
    end
    else begin
        valid_r <= valid_w;
        im1_r   <= im1_w  ;
        im2_r   <= im2_w  ;
        im3_r   <= im3_w  ;
        im4_r   <= im4_w  ;
        im5_r   <= im5_w  ;
        im6_r   <= im6_w  ;
        im7_r   <= im7_w  ;
        im8_r   <= im8_w  ;
        im9_r   <= im9_w  ;
        ker1_r  <= ker1_w ;
        ker2_r  <= ker2_w ;
        ker3_r  <= ker3_w ;
        ker4_r  <= ker4_w ;
        ker5_r  <= ker5_w ;
        ker6_r  <= ker6_w ;
        ker7_r  <= ker7_w ;
        ker8_r  <= ker8_w ;
        ker9_r  <= ker9_w ;
        skip_r  <= skip   ;

        Q_frac_reg <= Q_frac_wire;
    end
end

wire [4:0] Q_frac_wire;
wire [4:0] Q_frac_wire2 = Q_frac_reg;
MX#(5) mux1(Q_frac_wire, Q_frac, Q_frac_wire2, i_inhibit, numbers[10]);

reg [50:0] sum;
integer j;
always @(*) begin
	sum = 0;
	for (j=0; j<11; j=j+1) begin 
		sum = sum + numbers[j];
	end
end

assign o_transistor_num = sum;

endmodule
