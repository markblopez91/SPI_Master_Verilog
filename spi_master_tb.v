`timescale 1ns / 1ps

module spi_master_tb;

reg clk;
reg rst;
reg start;
reg [7:0] data_in;

wire mosi;
wire sclk;
wire cs;
wire busy;
wire done;

spi_master uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_in),
    .mosi(mosi),
    .sclk(sclk),
    .cs(cs),
    .busy(busy),
    .done(done)
);

// 100 MHz clock
always #5 clk = ~clk;

initial
begin
    clk = 0;
    rst = 1;
    start = 0;
    data_in = 8'h00;

    #100;
    rst = 0;

    #100;

    // Send A5 over SPI
    data_in = 8'hA5;
    start = 1;

    #10;
    start = 0;

    #3000;

    // Send 3C over SPI
    data_in = 8'h3C;
    start = 1;

    #10;
    start = 0;

    #3000;

    $stop;
end

endmodule