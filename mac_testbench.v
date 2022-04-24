`timescale 1ns/1ps
`define CYCLE      0.800

module mac_testbench();

//-- Generate System Signal
reg clk;
reg rstn;
reg sim_begin;
parameter N = 128;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars;
    clk  = 0;
    rstn = 0;
    sim_begin = 0;

    #(10*`CYCLE) rstn = 1; // our system is active-low reset.
    #30 sim_begin = 1;
end

always begin
    #(`CYCLE/2) clk = ~clk;
end

integer latency;
always @(posedge clk or negedge rstn) begin 
    if (~rstn) begin 
        latency = -1;
    end
    else begin
        latency = latency + 1;
    end
end

//-- Image / Weight / Golden Memory (65536)
reg [24-1:0] IMG_MEM [0:N];
reg [24-1:0] WGT_MEM [0:N];
reg [16-1:0] OUT_MEM [0:N];
reg [16-1:0] GOLD_MEM [0:N];

reg [17-1:0] mem_address, out_address;

reg  [24-1:0] img_in, wgt_in;
wire [16-1:0] out_golden;

wire o_valid;

initial begin
    // NOTE: We could add @ in dram_model.dat to force jumping the address while reading...
    @(posedge (rstn));
    #2;
    $readmemh("mem_img_N_128.mem", IMG_MEM);
    $readmemh("mem_wgt_N_128.mem", WGT_MEM);
    $readmemh("mem_out_N_128.mem", GOLD_MEM);

    //  $readmemh("mem_img_N_4096.mem", IMG_MEM);
    //  $readmemh("mem_wgt_N_4096.mem", WGT_MEM);
    //  $readmemh("mem_out_N_4096.mem", GOLD_MEM);

    // $readmemh("mem_img_N_100000.mem", IMG_MEM);
    // $readmemh("mem_wgt_N_100000.mem", WGT_MEM);
    // $readmemh("mem_out_N_100000.mem", GOLD_MEM);
end

//-- Read Memory
always @(posedge clk) begin
    if (~rstn) begin
        img_in <= 0;
        wgt_in <= 0;

        mem_address <= 0;
        out_address <= 0;
    end
    else begin
        if (sim_begin) begin
            img_in <= IMG_MEM[mem_address];
            wgt_in <= WGT_MEM[mem_address];
            
            mem_address <= mem_address + 1;
            out_address <= (o_valid) ? out_address + 1 : out_address;
        end
        else begin
            img_in <= 0;
            wgt_in <= 0;

            mem_address <= mem_address;
            out_address <= out_address;
        end
    end
end

//-- Write Memory
wire [16-1:0] o_conv;
always @(posedge clk) begin
    if (o_valid) begin
        OUT_MEM[out_address] <= o_conv;
    end
end

assign out_golden = (o_valid) ? GOLD_MEM[out_address] : 0;

//-- Row assign
wire [8-1:0] img_row1_in = img_in[ 7: 0];
wire [8-1:0] img_row2_in = img_in[15: 8];
wire [8-1:0] img_row3_in = img_in[23:16];

wire [4-1:0] wgt_row1_in = wgt_in[ 3: 0];
wire [4-1:0] wgt_row2_in = wgt_in[11: 8];
wire [4-1:0] wgt_row3_in = wgt_in[19:16];


//-- Row delay
reg [8-1:0] i_im1, i_im2, i_im3, i_im4, i_im5, i_im6, i_im7, i_im8, i_im9;
reg [4-1:0] i_ker1, i_ker2, i_ker3, i_ker4, i_ker5, i_ker6, i_ker7, i_ker8, i_ker9;

always @(posedge clk) begin
    if (~rstn) begin
        i_im1 <= 0; i_im2 <= 0; i_im3 <= 0; i_im4 <= 0; i_im5 <= 0; i_im6 <= 0; i_im7 <= 0; i_im8 <= 0; i_im9 <= 0;
        i_ker1 <= 0; i_ker2 <= 0; i_ker3 <= 0; i_ker4 <= 0; i_ker5 <= 0; i_ker6 <= 0; i_ker7 <= 0; i_ker8 <= 0; i_ker9 <= 0;
    end
    else begin
        i_im1 <= i_im2;
        i_im2 <= i_im3;
        i_im3 <= img_row1_in;
        i_im4 <= i_im5;
        i_im5 <= i_im6;
        i_im6 <= img_row2_in;
        i_im7 <= i_im8;
        i_im8 <= i_im9;
        i_im9 <= img_row3_in;

        i_ker1 <= i_ker2;
        i_ker2 <= i_ker3;
        i_ker3 <= wgt_row1_in;
        i_ker4 <= i_ker5;
        i_ker5 <= i_ker6;
        i_ker6 <= wgt_row2_in;
        i_ker7 <= i_ker8;
        i_ker8 <= i_ker9;
        i_ker9 <= wgt_row3_in;
    end
end


wire i_valid = ( mem_address >= 4 && mem_address <= N+1 ) ? 1 : 0;

wire error = ( (o_conv !== out_golden) && o_valid ) ? 1 : 0;
reg [16-1:0] error_count;
always @(posedge clk) begin
    if (~rstn)
        error_count <= 0;
    else
        error_count <= (error) ? error_count + 1 : error_count;
end

reg error_more_than_1, error_more_than_2, error_more_than_3, error_more_than_4, error_more_than_5, error_more_than_6, error_more_than_7, error_more_than_8, error_more_than_9;
always @(*) begin
    if (o_conv[14:0] > out_golden[14:0]) begin
        error_more_than_1 = (o_conv[14:0] - out_golden[14:0] > 1) ? 1 : 0;
        error_more_than_2 = (o_conv[14:0] - out_golden[14:0] > 2) ? 1 : 0;
        error_more_than_3 = (o_conv[14:0] - out_golden[14:0] > 3) ? 1 : 0;
        error_more_than_4 = (o_conv[14:0] - out_golden[14:0] > 4) ? 1 : 0;
        error_more_than_5 = (o_conv[14:0] - out_golden[14:0] > 5) ? 1 : 0;
        error_more_than_6 = (o_conv[14:0] - out_golden[14:0] > 6) ? 1 : 0;
        error_more_than_7 = (o_conv[14:0] - out_golden[14:0] > 7) ? 1 : 0;
        error_more_than_8 = (o_conv[14:0] - out_golden[14:0] > 8) ? 1 : 0;
        error_more_than_9 = (o_conv[14:0] - out_golden[14:0] > 9) ? 1 : 0;
    end
    else begin
        error_more_than_1 = (out_golden[14:0] - o_conv[14:0] > 1) ? 1 : 0;
        error_more_than_2 = (out_golden[14:0] - o_conv[14:0] > 2) ? 1 : 0;
        error_more_than_3 = (out_golden[14:0] - o_conv[14:0] > 3) ? 1 : 0;
        error_more_than_4 = (out_golden[14:0] - o_conv[14:0] > 4) ? 1 : 0;
        error_more_than_5 = (out_golden[14:0] - o_conv[14:0] > 5) ? 1 : 0;
        error_more_than_6 = (out_golden[14:0] - o_conv[14:0] > 6) ? 1 : 0;
        error_more_than_7 = (out_golden[14:0] - o_conv[14:0] > 7) ? 1 : 0;
        error_more_than_8 = (out_golden[14:0] - o_conv[14:0] > 8) ? 1 : 0;
        error_more_than_9 = (out_golden[14:0] - o_conv[14:0] > 9) ? 1 : 0;
    end

end

wire [50:0] o_transistor_num;

mac        DUT(.clk(clk),
               .i_rst_n(rstn),
               .i_inhibit(1'b0),
               .i_valid(i_valid),
               .i_q(9'd17),
               .zero_vector(9'd0),

               // input pixels
               .i_im1(i_im1),
               .i_im2(i_im2),
               .i_im3(i_im3),
               .i_im4(i_im4),
               .i_im5(i_im5),
               .i_im6(i_im6),
               .i_im7(i_im7),
               .i_im8(i_im8),
               .i_im9(i_im9),

               // input weights
               .i_ker1(i_ker1),
               .i_ker2(i_ker2),
               .i_ker3(i_ker3),
               .i_ker4(i_ker4),
               .i_ker5(i_ker5),
               .i_ker6(i_ker6),
               .i_ker7(i_ker7),
               .i_ker8(i_ker8),
               .i_ker9(i_ker9),

               // output ports
               .o_valid(o_valid),
               .o_conv(o_conv),
               .o_transistor_num(o_transistor_num)
              );

integer l_p = 0;
integer out_batch;
always @(posedge clk) begin
    if (o_valid == 0 && mem_address > N+100) begin
        $display("latency: %d", latency);
        $display("transistor numbers: %d", o_transistor_num);
        //-- Since the result has written back to the DRAM, we can write the result to the text file to check the content is correct or not.
        $display("---------------------------");
        $display("Writing result");
        $display("---------------------------"); //-- verbose the debugging messages.

        //-- file open for the case we are going to print out the message to text.
        out_batch = $fopen("result.txt", "w");

        for(l_p = 0; l_p<N-2; l_p=l_p+1) begin
            $fwrite(out_batch, "%04X\n" , OUT_MEM[l_p]);
        end
        //  -- Close the file for the case that we finished the writing task.
        $fclose(out_batch);
        $display("--- Writing DONE!! ---"); // verbose the debugging message.

        $finish;
    end
end


endmodule
