`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 21:24:07
// Design Name: 
// Module Name: ahb_slave
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


module ahb_slave(
  
  input hclk,
  input hresetn,
  input hsel,
  input [31:0] haddr,
  input hwrite,
  input [2:0] hsize,
  input [2:0] hburst,
  input [3:0] hprot,
  input [1:0] htrans,
  input hmastlock,
  input [31:0] hwdata,
  input hready,
  
  output reg hreadyout,
  output reg hresp,
  output reg [31:0] hrdata
  );
  
  reg [31:0] mem [31:0];
  reg [4:0] waddr;
  reg [4:0] raddr;
  
  reg [1:0] present_state, next_state;
  parameter idle = 2'b00;
  parameter s1 = 2'b01;
  parameter s2 = 2'b10;
  parameter s3 = 2'b11;
  
  reg single_flag;
  reg incr_flag;
  reg incr4_flag;
  reg incr8_flag;
  reg incr16_flag;
  reg wrap4_flag;
  reg wrap8_flag;
  reg wrap16_flag;
  
  always @(posedge hclk)
      begin
          if ( !hresetn )
              present_state <= idle;
          else 
              present_state <= next_state;
      end
      
  always @(posedge hclk) 
      begin
          case (present_state) 
            idle: 
                begin
                    single_flag <= 1'b0;
                    incr_flag <= 1'b0;
                    incr4_flag <= 1'b0;
                    incr8_flag <= 1'b0;
                    incr16_flag <= 1'b0;
                    wrap4_flag <= 1'b0;
                    wrap8_flag <= 1'b0;
                    wrap16_flag <= 1'b0;
                    
                    if (hsel == 1'b1) 
                        next_state <= s1;
                    else 
                        next_state <= idle;
                end
                
            s1:
                begin
                    case (hburst)
                        // single burst transfer
                        
                        3'b000:
                            begin
                                single_flag <= 1'b1;
                                incr_flag <= 1'b0;
                                incr4_flag <= 1'b0;
                                incr8_flag <= 1'b0;
                                incr16_flag <= 1'b0;
                                wrap4_flag <= 1'b0;
                                wrap8_flag <= 1'b0;
                                wrap16_flag <= 1'b0;
                            end
                            
                        3'b001:
                            begin
                                single_flag <= 1'b0;
                                incr_flag <= 1'b1;
                                incr4_flag <= 1'b0;
                                incr8_flag <= 1'b0;
                                incr16_flag <= 1'b0;
                                wrap4_flag <= 1'b0;
                                wrap8_flag <= 1'b0;
                                wrap16_flag <= 1'b0;
                            end 
                            
                        3'b010:
                            begin
                                single_flag <= 1'b0;
                                incr_flag <= 1'b0;
                                incr4_flag <= 1'b0;
                                incr8_flag <= 1'b0;
                                incr16_flag <= 1'b0;
                                wrap4_flag <= 1'b1;
                                wrap8_flag <= 1'b0;
                                wrap16_flag <= 1'b0;
                            end
                            
                        3'b011:
                            begin
                                single_flag <= 1'b0;
                                incr_flag <= 1'b0;
                                incr4_flag <= 1'b1;
                                incr8_flag <= 1'b0;
                                incr16_flag <= 1'b0;
                                wrap4_flag <= 1'b0;
                                wrap8_flag <= 1'b0;
                                wrap16_flag <= 1'b0;
                            end
                            
                        3'b100:
                            begin
                                single_flag <= 1'b0;
                                incr_flag <= 1'b0;
                                incr4_flag <= 1'b0;
                                incr8_flag <= 1'b0;
                                incr16_flag <= 1'b0;
                                wrap4_flag <= 1'b0;
                                wrap8_flag <= 1'b1;
                                wrap16_flag <= 1'b0;
                            end
                            
                        3'b101:
                            begin
                                single_flag <= 1'b0;
                                incr_flag <= 1'b0;
                                incr4_flag <= 1'b0;
                                incr8_flag <= 1'b1;
                                incr16_flag <= 1'b0;
                                wrap4_flag <= 1'b0;
                                wrap8_flag <= 1'b0;
                                wrap16_flag <= 1'b0;
                            end
                            
                        3'b110: 
                            begin
                                single_flag <= 1'b0;
                                incr_flag <= 1'b0;
                                incr4_flag <= 1'b0;
                                incr8_flag <= 1'b1;
                                incr16_flag <= 1'b0;
                                wrap4_flag <= 1'b0;
                                wrap8_flag <= 1'b0;
                                wrap16_flag <= 1'b1;
                            end
                            
                        3'b111:
                            begin
                                single_flag <= 1'b0;
                                incr_flag <= 1'b0;
                                incr4_flag <= 1'b0;
                                incr8_flag <= 1'b0;
                                incr16_flag <= 1'b1;
                                wrap4_flag <= 1'b0;
                                wrap8_flag <= 1'b0;
                                wrap16_flag <= 1'b0;
                            end
                            
                        default :
                            begin
                                single_flag <= 1'b0;
                                incr_flag <= 1'b0;
                                incr4_flag <= 1'b0;
                                incr8_flag <= 1'b1;
                                incr16_flag <= 1'b0;
                                wrap4_flag <= 1'b0;
                                wrap8_flag <= 1'b0;
                                wrap16_flag <= 1'b0;
                            end
                    endcase
                    
                    // write operation
                    if ((hwrite == 1'b1) && (hready == 1'b1))
                        begin
                            next_state <= s2;
                        end
                    
                    // read operation   
                    else if ((hwrite == 1'b0) && (hready == 1'b1)) 
                        begin
                            next_state <= s3;
                        end
                        
                    else 
                        begin
                            next_state <= s1;
                        end
                end
                
            s2 :
                begin
                    case (hburst)
                        3'b000 :
                            if (hsel == 1'b1) 
                                begin
                                  next_state <= s1;
                                end   
                            else 
                                begin
                                    next_state <= idle;
                                end
                                
                        // incrementing burst of undefined length
                        3'b001 :
                            next_state <= s2;
                        
                        // 4-beat wrapping burst    
                        3'b010 :
                            next_state <= s2;
                            
                        // 4-beat incrementing burst
                        3'b011 :
                            next_state <= s2;
                            
                        // 8-beat wrapping burst
                        3'b100 :
                            next_state <= s2;
                        
                        // 8-beat incrementing burst
                        3'b101 :
                            next_state <= s2;
                        
                        // 16-beat wrapping burst
                        3'b110 :
                            next_state <= s2;
                            
                        // 16-beat wrapping burst
                        3'b111 :
                            next_state <= s2;
                            
                        default :
                            begin
                                if (hsel == 1'b1)
                                    begin
                                        next_state <= s1;
                                    end
                                else
                                    begin
                                        next_state <= idle;
                                    end
                            end
                    endcase
                end
                
            s3 : 
                begin
                    case (hburst)
                        
                        // single transfer burst
                        3'b000 :
                            begin
                                if (hsel == 1'b1)
                                    begin
                                        next_state <= s1;
                                    end
                                else begin
                                    next_state <= idle;
                                end
                            end
                        
                        // incrementing burst of indefined length
                        3'b001 :
                            next_state <= s3;
                            
                        // 4-beat wrapping burst
                        3'b010 :
                            next_state <= s3;
                            
                        // 8-beat wrapping burst
                        3'b011 :
                            next_state <= s3;
                            
                        // 8-beat incrementing burst
                        3'b100 :
                            next_state <= s3;
                            
                        // 8-beat incrementing burst
                        3'b101 :
                            next_state <= s2;
                        
                        // 16-beat wrapping burst
                        3'b110 :
                            next_state <= s2;
                            
                        // 16-beat wrapping burst
                        3'b111 :
                            next_state <= s2;
                            
                        default :
                            begin
                                if (hsel == 1'b1)
                                    begin
                                        next_state <= s1;
                                    end
                                else
                                    begin
                                        next_state <= idle;
                                    end
                            end
                    endcase 
                end
                
            default : 
                begin
                    next_state <= idle;
                end
          endcase
      end
    
    always @(posedge hclk)
        begin
            if (!hresetn)
                begin
                    hreadyout <= 1'b0;
                    hresp <= 1'b0;
                    hrdata <= 1'b0;
                    waddr <= waddr;
                    raddr <= raddr;
                end
            else 
                begin
                    case (next_state)
                        
                        idle :
                            begin
                                hreadyout <= 1'b0;
                                hresp <= 1'b0;
                                hrdata <= hrdata;
                                waddr <= waddr;
                                raddr <= raddr;
                            end
                            
                        s1 :
                            begin
                                hreadyout <= 1'b0;
                                hresp <= 1'b0;
                                hrdata <= hrdata;
                                waddr <= haddr;
                                raddr <= haddr;
                            end
                            
                        s2 : // write transfer
                            begin
                                case ({single_flag, incr_flag, wrap4_flag, incr4_flag, wrap8_flag, incr8_flag, wrap16_flag, incr16_flag})
                                
                                // single transfer
                                8'b1000_0000 :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                        mem[waddr] <= hwdata;
                                    end
                                    
                                // incrementing
                                8'b0100_0000 :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                        mem[waddr] <= hwdata;
                                        waddr <= waddr + 1'b1;
                                    end
                                    
                                // wrap 4
                                8'b0010_0000 :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                        if (waddr < (haddr + 2'd3))
                                            begin
                                                waddr <= waddr + 1;
                                            end
                                        else
                                            begin
                                                mem[waddr] <= hwdata;
                                                waddr <= haddr;
                                            end
                                    end
                                    
                                // inc 4
                                8'b0001_0000 :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                        mem[waddr] <= hwdata;
                                        waddr <= waddr + 1;
                                    end
                                    
                                // wrap 8
                                8'b0000_1000 :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                        
                                        if (waddr < (haddr + 3'd7))
                                            begin
                                                mem[waddr] <= hwdata;
                                                waddr <= waddr + 1;
                                            end
                                    end
                                    
                                // inc 8
                                8'b0000_0100 :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                        mem[waddr] <= hwdata;
                                        waddr <= waddr + 1;
                                    end
                                
                                // wrap 16
                                8'b0000_0010 :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                        
                                        if (waddr < (haddr + 4'd15))
                                            begin
                                                mem[waddr] <= hwdata;
                                                waddr <= waddr + 1;
                                            end
                                        else
                                            begin
                                                mem[waddr] <= hwdata;
                                                waddr <= haddr;
                                            end
                                    end
                                    
                                // incr 16
                                8'b0000_0001 :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                        mem[waddr] <= hwdata;
                                        waddr <= waddr + 1;
                                    end
                                    
                                default :
                                    begin
                                        hreadyout <= 1'b1;
                                        hresp <= 1'b0;
                                    end
                            endcase
                        end
                        
                        s3 : 
                            begin
                                case ({single_flag, incr_flag, wrap4_flag, incr4_flag, wrap8_flag, incr8_flag, wrap16_flag, incr16_flag})
                                    
                                    // single transfer
                                    8'b1000_0000 :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                            hrdata <= mem[raddr];
                                        end
                                        
                                    // incr transfer
                                    8'b0100_0000 :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                            hrdata <= mem[raddr];
                                            raddr <= raddr + 1;
                                        end
                                        
                                    // wrap 4
                                    8'b0010_0000 :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                            
                                            if (hrdata < (haddr + 2'd3))
                                                begin
                                                    hrdata <= mem[raddr];
                                                    raddr <= raddr + 1'b1;
                                                end
                                            else 
                                                begin
                                                    hrdata <= mem[raddr];
                                                    raddr <= haddr;
                                                end
                                        end
                                        
                                    // incr 4
                                    8'b0001_0000 :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                            hrdata <= mem[raddr];
                                            raddr <= raddr + 1'b1;
                                        end
                                        
                                    // wrap 8
                                    8'b0000_1000 :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                            
                                            if (hrdata < (haddr + 3'd7))
                                                begin
                                                    hrdata <= mem[raddr];
                                                    raddr <= raddr + 1'b1;
                                                end
                                            else 
                                                begin
                                                    hrdata <= mem[raddr];
                                                    raddr <= haddr;
                                                end
                                        end
                                        
                                    // incr 8
                                    8'b0000_0100 :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                            hrdata <= mem[raddr];
                                            raddr <= raddr + 1'b1;
                                        end
                                        
                                    // wrap 16
                                    8'b0000_0010 :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                            
                                            if (hrdata < (haddr + 4'd15))
                                                begin
                                                    hrdata <= mem[raddr];
                                                    raddr <= raddr + 1'b1;
                                                end
                                            else 
                                                begin
                                                    hrdata <= mem[raddr];
                                                    raddr <= haddr;
                                                end
                                        end
                                        
                                    // incr 8
                                    8'b0000_0001 :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                            hrdata <= mem[raddr];
                                            raddr <= raddr + 1'b1;
                                        end
                                        
                                    default :
                                        begin
                                            hreadyout <= 1'b1;
                                            hresp <= 1'b0;
                                        end
                                endcase
                            end
                            
                        default :
                            begin
                                hreadyout <= 1'b0;
                                hresp <= 1'b0;
                                waddr <= waddr;
                                raddr <= raddr;
                            end
                    endcase
                end
        end
endmodule
