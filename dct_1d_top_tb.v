`timescale 1ns/1ps

module dct_1d_top_tb;

reg clk, rst, write_en;
reg [2:0] addr;
reg signed [15:0] data_in;
wire signed [15:0] data_out;

dct_1d_top uut (
    .clk(clk), .rst(rst),
    .addr(addr), .data_in(data_in),
    .write_en(write_en),
    .data_out(data_out)
);

always #10 clk = ~clk;

task write_pixel;
    input [2:0] a;
    input signed [15:0] val;
    begin
        addr     <= a;
        data_in  <= val;
        write_en <= 1;
        @(posedge clk);
        write_en <= 0;
        @(posedge clk);
    end
endtask

task read_result;
    input [2:0] a;
    begin
        addr <= a;
        @(posedge clk);
        @(posedge clk);
        $display("X[%0d] = %0d", a, data_out);
    end
endtask

integer i;

initial begin
    clk = 0; rst = 1; write_en = 0;
    addr = 0; data_in = 0;

    @(posedge clk);
    @(posedge clk);
    rst = 0;
    @(posedge clk);

    // -------------------------------------------------------
    // Test 1: all zeros
    // -------------------------------------------------------
    $display("--- Test 1: all zeros ---");
    write_pixel(0, 16'sd0);
    write_pixel(1, 16'sd0);
    write_pixel(2, 16'sd0);
    write_pixel(3, 16'sd0);
    write_pixel(4, 16'sd0);
    write_pixel(5, 16'sd0);
    write_pixel(6, 16'sd0);
    write_pixel(7, 16'sd0);

    // Wait for pipeline: COMPUTE + OUTPUT = 2 cycles
    repeat(6) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) read_result(i);

    // -------------------------------------------------------
    // Test 2: all same value (DC only)
    // -------------------------------------------------------
    $display("--- Test 2: all same value (DC only) ---");
    write_pixel(0, 16'sd10);
    write_pixel(1, 16'sd10);
    write_pixel(2, 16'sd10);
    write_pixel(3, 16'sd10);
    write_pixel(4, 16'sd10);
    write_pixel(5, 16'sd10);
    write_pixel(6, 16'sd10);
    write_pixel(7, 16'sd10);

    repeat(6) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) read_result(i);

    // -------------------------------------------------------
    // Test 3: JPEG row 0 level shifted
    // {139,144,149,153,155,155,155,155} - 128
    // -------------------------------------------------------
    $display("--- Test 3: JPEG row 0 level shifted ---");
    write_pixel(0, 16'sd11);
    write_pixel(1, 16'sd16);
    write_pixel(2, 16'sd21);
    write_pixel(3, 16'sd25);
    write_pixel(4, 16'sd27);
    write_pixel(5, 16'sd27);
    write_pixel(6, 16'sd27);
    write_pixel(7, 16'sd27);

    repeat(6) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) read_result(i);

    // -------------------------------------------------------
    // Test 4: JPEG row 3 level shifted
    // {159,161,162,160,160,159,159,159} - 128
    // -------------------------------------------------------
    $display("--- Test 4: JPEG row 3 level shifted ---");
    write_pixel(0, 16'sd31);
    write_pixel(1, 16'sd33);
    write_pixel(2, 16'sd34);
    write_pixel(3, 16'sd32);
    write_pixel(4, 16'sd32);
    write_pixel(5, 16'sd31);
    write_pixel(6, 16'sd31);
    write_pixel(7, 16'sd31);

    repeat(6) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) read_result(i);

    // -------------------------------------------------------
    // Test 5: alternating max frequency
    // -------------------------------------------------------
    $display("--- Test 5: alternating max frequency ---");
    write_pixel(0,  16'sd100);
    write_pixel(1, -16'sd100);
    write_pixel(2,  16'sd100);
    write_pixel(3, -16'sd100);
    write_pixel(4,  16'sd100);
    write_pixel(5, -16'sd100);
    write_pixel(6,  16'sd100);
    write_pixel(7, -16'sd100);

    repeat(6) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) read_result(i);

    $display("--- Done ---");
    $stop;
end

endmodule