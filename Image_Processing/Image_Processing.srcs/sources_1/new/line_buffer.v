`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 07:36:48 PM
// Design Name: 
// Module Name: line_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module line_buffer#
(
    parameter integer IMG_WIDTH_MAX = 640
)
(
    input clk,
    input rst_n,
    input [7:0] pix_in,
    input pix_wr,
    input [15:0] img_width,
    output [71:0] window,
    output reg window_valid
    );
    
reg [15:0] col_cnt;
reg [15:0] row_cnt;
reg [1:0] row_ptr;  // current row
wire [1:0] row_mid;  // recent row
wire [1:0] row_old;  // oldest row

// row buffers
reg [7:0] row_buf [0:2] [0:IMG_WIDTH_MAX-1];

// window buffers, to be indexed by win[row][0..2]
reg [7:0] win[0:2][0:2];

assign row_mid = (row_ptr == 0) ? 2 : (row_ptr == 1) ? 0 : 1;
assign row_old = (row_ptr == 0) ? 1 : (row_ptr == 1) ? 2 : 0;

assign window[71:64] = win[row_old][0];
assign window[63:56] = win[row_old][1];
assign window[55:48] = win[row_old][2];

assign window[47:40] = win[row_mid][0];
assign window[39:32] = win[row_mid][1];
assign window[31:24] = win[row_mid][2];

assign window[23:16] = win[row_ptr][0];
assign window[15:8]  = win[row_ptr][1];
assign window[7:0]   = pix_in;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        window_valid <= 0;
        col_cnt <= 0;
        row_cnt <= 0;
        row_ptr <= 0;
    end
    else begin
        window_valid <= 0;
        
        if (pix_wr) begin
            row_buf[row_ptr][col_cnt] <= pix_in;
            
            if (col_cnt == img_width - 1) begin
                col_cnt <= 0;
                row_ptr <= (row_ptr == 2) ? 0 : row_ptr + 1;
                row_cnt <= row_cnt + 1;
            end else begin
                col_cnt <= col_cnt + 1;
            end
            
            if (row_cnt >= 2) begin
                win[row_ptr][0] <= win[row_ptr][1];
                win[row_ptr][1] <= win[row_ptr][2];
                win[row_ptr][2] <= pix_in;
                
                win[row_mid][0] <= win[row_mid][1];
                win[row_mid][1] <= win[row_mid][2];
                win[row_mid][2] <= row_buf[row_mid][col_cnt];
                
                win[row_old][0] <= win[row_old][1];
                win[row_old][1] <= win[row_old][2];
                win[row_old][2] <= row_buf[row_old][col_cnt];
                
                if (col_cnt >= 2) begin
                    window_valid <= 1;
                end
            end
        end
    end
end
endmodule
