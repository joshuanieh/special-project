
module PPgenerator(
           input [8-1: 0] image,
           input [4-1: 0] weight,
           output [4-1:0] denorm_pp,
           output [6-1:0] exp,
           output [50:0] number
       );

wire [50:0] numbers [0:8];


// image
// | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
// | S |     Exponent      | Mant. |
wire         image_sign = image[7];
wire [5-1:0] image_exp  = image[6:2];
wire [2-1:0] image_mant = image[1:0];

// weight
// | 3 | 2 | 1 | 0 |
// | S |  Exponent |
wire         weight_sign = weight[3];
wire [3-1:0] weight_exp  = weight[2:0];

// Add zero floag in case the image or weight is zero
// wire zero_img_flag = image[6:0] == 0;
wire zero_img_flag;
wire [1:0] img_flag_tmp;
OR3 or_img_flag_1(img_flag_tmp[0], image[2], image[1], image[0], numbers[0]);
OR4 or_img_flag_2(img_flag_tmp[1], image[6], image[5], image[4], image[3], numbers[1]);
NR2 or_img_flag_3(zero_img_flag, img_flag_tmp[0], img_flag_tmp[1], numbers[2]);
// wire zero_wgt_flag = weight_exp == 3'b111;
wire zero_wgt_flag;
AN3 and_wgt_flag(zero_wgt_flag, weight_exp[2], weight_exp[1], weight_exp[0], numbers[3]);
wire zero_flag;
// wire zero_flag     = zero_img_flag || zero_wgt_flag;
OR2 or1(zero_flag, zero_img_flag, zero_wgt_flag, numbers[4]);


// Denormalize partial product
// denorm_pp
// | 3 |  2 | 1 | 0 |
// | S | ld .       |
wire denorm_sign;
// wire denorm_sign = image_sign ^ weight_sign;
EO eo1(denorm_sign, image_sign, weight_sign, numbers[5]);
wire [4-1:0] denorm_pp_with_leading_one = {denorm_sign, 1'b1, image_mant};

wire denorm_pp;
// assign denorm._pp = (zero_flag) ? 4'd0 : denorm_pp_with_leading_one;
MX#(4) mux1(denorm_pp, denorm_pp_with_leading_one, 4'd0, zero_flag, numbers[6]);
wire exp;
// assign exp = (zero_flag) ? 6'd0 : image_exp + weight_exp;
wire [4:0] fa_sum;
wire fa_carry;
ADD#(5) fa1(image_exp, {2'b0, weight_exp}, fa_sum, fa_carry, numbers[7]);
MX#(6) mux2(exp, {fa_carry, fa_sum}, 6'd0, zero_flag, numbers[8]);

reg [50:0] sum;
integer j;
always @(*) begin
	sum = 0;
	for (j=0; j<9; j=j+1) begin 
		sum = sum + numbers[j];
	end
end

assign number = sum;

endmodule
