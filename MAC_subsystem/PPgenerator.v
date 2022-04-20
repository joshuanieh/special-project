
module PPgenerator(
           input [8-1: 0] image,
           input [4-1: 0] weight,
           output [4-1:0] denorm_pp,
           output [6-1:0] exp
       );


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
wire zero_img_flag = image[6:0] == 0;
wire zero_wgt_flag = weight_exp == 3'b111;
wire zero_flag     = zero_img_flag || zero_wgt_flag;


// Denormalize partial product
// denorm_pp
// | 3 |  2 | 1 | 0 |
// | S | ld .       |
wire denorm_sign = image_sign ^ weight_sign;
wire [4-1:0] denorm_pp_with_leading_one = {denorm_sign, 1'b1, image_mant};

assign denorm_pp = (zero_flag) ? 4'd0 : denorm_pp_with_leading_one;
assign exp = (zero_flag) ? 6'd0 : image_exp + weight_exp;


endmodule
