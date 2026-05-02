`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 07:36:48 PM
// Design Name: 
// Module Name: conv_engine
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


module conv_engine(
    input clk,
    input rst_n,
    input [71:0] window,
    input window_valid,
    input [71:0] kernel,
    input [7:0] scale,
    input [8:0] bias,
    output reg [7:0] pix_out,
    output reg pix_valid,
    output reg overflow
    );
       
    wire signed [15:0] prod[8:0];
    wire [7:0] p[8:0];
    wire signed [7:0] k[8:0];
    reg signed [19:0] acc;
    reg signed[19:0] scaled;
    reg signed[20:0] biased;

    genvar i;   
    generate 
        for (i = 0; i <= 8; i = i + 1) begin
            assign p[i] = window[i*8 +: 8];
            assign k[i] = $signed(kernel[i*8 +: 8]); 
            assign prod[i] = k[i] * $signed({1'b0, p[i]});
        end
    endgenerate 
    
    integer j;
    always @(*) begin
        acc = 20'sd0;
        for (j = 0; j < 9; j = j + 1) begin
            acc = acc + prod[j];
        end
        
        case (scale)
            8'd1:       scaled = acc;
            8'd9:       scaled = ($signed(acc) * 20'sd57) >>> 9; // fast divide-by-9 trick
            default:    scaled = acc;
        endcase
        
        biased = $signed(scaled) + $signed(bias);
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pix_out <= 0;
            pix_valid <= 0;
            overflow <= 0;
        end
        else begin
            pix_valid <= 1'b0;
            if (window_valid) begin
                if (biased < 0) begin
                    pix_out <= 0;
                    overflow <= 1;
                    pix_valid <= 1;
                end else if (biased > 255) begin
                    pix_out <= 255;
                    overflow <= 1;
                    pix_valid <= 1;
                end else begin // non-clamped behavior
                    pix_out <= biased[7:0];
                    overflow <= 0;
                    pix_valid <= 1;
                end
            end
        end
    end
    
endmodule