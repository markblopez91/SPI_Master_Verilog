`timescale 1ns / 1ps

module spi_master(
    input clk,
    input rst,
    input start,
    input [7:0] data_in,
    output reg mosi,
    output reg sclk,
    output reg cs,
    output reg busy,
    output reg done
);

parameter CLK_DIV = 10;

reg [7:0] shift_reg;
reg [2:0] bit_count;
reg [7:0] clk_count;
reg [1:0] state;

localparam IDLE     = 2'b00;
localparam TRANSFER = 2'b01;
localparam DONE     = 2'b10;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        mosi <= 1'b0;
        sclk <= 1'b0;
        cs <= 1'b1;
        busy <= 1'b0;
        done <= 1'b0;
        shift_reg <= 8'b0;
        bit_count <= 3'b0;
        clk_count <= 8'b0;
        state <= IDLE;
    end
    else
    begin
        case (state)

            IDLE:
            begin
                sclk <= 1'b0;
                cs <= 1'b1;
                busy <= 1'b0;
                done <= 1'b0;
                clk_count <= 8'b0;
                bit_count <= 3'b0;

                if (start)
                begin
                    shift_reg <= data_in;
                    mosi <= data_in[7];
                    cs <= 1'b0;
                    busy <= 1'b1;
                    state <= TRANSFER;
                end
            end

            TRANSFER:
            begin
                busy <= 1'b1;
                done <= 1'b0;

                if (clk_count < CLK_DIV - 1)
                begin
                    clk_count <= clk_count + 1;
                end
                else
                begin
                    clk_count <= 0;
                    sclk <= ~sclk;

                    if (sclk == 1'b1)
                    begin
                        if (bit_count < 7)
                        begin
                            bit_count <= bit_count + 1;
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            mosi <= shift_reg[6];
                        end
                        else
                        begin
                            state <= DONE;
                        end
                    end
                end
            end

            DONE:
            begin
                cs <= 1'b1;
                sclk <= 1'b0;
                busy <= 1'b0;
                done <= 1'b1;
                state <= IDLE;
            end

            default:
            begin
                state <= IDLE;
            end

        endcase
    end
end

endmodule