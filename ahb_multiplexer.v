`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2024 01:04:56
// Design Name: 
// Module Name: ahb_multiplexer
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


module ahb_multiplexer(

    input [1:0] sel,
    input [31:0] hrdata_1,
    input [31:0] hrdata_2,
    input [31:0] hrdata_3,
    input [31:0] hrdata_4,
    
    input hreadyout_1,
    input hreadyout_2,
    input hreadyout_3,
    input hreadyout_4,
    
    input hresp_1,
    input hresp_2,
    input hresp_3,
    input hresp_4,
    
    output reg [31:0] hrdata,
    output reg hreadyout,
    output reg hresp
    );
    
    always @(*)
        begin
            
            case (sel) 
                
                2'b00 :
                    begin
                        hrdata <= hrdata_1;
                        hreadyout <= hreadyout_1;
                        hresp <= hresp_1;
                    end
                    
                2'b01 :
                    begin
                        hrdata <= hrdata_2;
                        hreadyout <= hreadyout_2;
                        hresp <= hresp_2;
                    end
                    
                2'b10 :
                    begin
                        hrdata <= hrdata_3;
                        hreadyout <= hreadyout_3;
                        hresp <= hresp_3;
                    end
                    
                2'b11 :
                    begin
                        hrdata <= hrdata_4;
                        hreadyout <= hreadyout_4;
                        hresp <= hresp_4;
                    end
                    
                default :
                    begin
                        begin
                        hrdata <= hrdata;
                        hreadyout <= hreadyout;
                        hresp <= hresp;
                    end 
                    end
            endcase
        end
endmodule
