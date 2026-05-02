`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 07:36:48 PM
// Design Name: 
// Module Name: image_filter
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


module image_filter#(
    parameter integer IMG_WIDTH_MAX = 640
)
(
    input clk,
    input rst_n,
    input [7:0] pix_in,
    input pix_wr,
    input [15:0] img_width,
    input [71:0] kernel,
    input [7:0] scale,
    input [8:0] bias,
    output [7:0] pix_out,
    output pix_valid,
    output overflow
    );
    
    wire [71:0] window;
    wire window_valid;
    
    line_buffer #(.IMG_WIDTH_MAX(IMG_WIDTH_MAX)) line_buffer_inst_ (
        .clk (clk),
        .rst_n (rst_n),
        .pix_in (pix_in),
        .pix_wr (pix_wr),
        .img_width (img_width),
        .window (window),
        .window_valid (window_valid)
    );
    
    conv_engine conv_engine_inst_ (
        .clk (clk),
        .rst_n (rst_n),
        .window (window),
        .window_valid (window_valid),
        .kernel (kernel),
        .scale (scale),
        .bias (bias),
        .pix_out (pix_out),
        .pix_valid (pix_valid),
        .overflow (overflow)
    );
    
endmodule

