`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/01/07 15:26:30
// Design Name: 
// Module Name: unsinttodouble
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


module unsinttodouble(
        input_a,
        clk,
        rst,
        en,
		complete,
        output_z);

  input     clk;
  input     rst;
input en;
  input     [31:0] input_a;
  output    [63:0] output_z;
  output complete;
  reg       [63:0] s_output_z;
  reg	 s_complete;

   reg       [2:0] state;
  parameter get_a         = 3'd0,
            convert_0     = 3'd1,
            convert_1     = 3'd2,
            convert_2     = 3'd3,
            round         = 3'd4,
            pack          = 3'd5,
            put_z         = 3'd6;

   reg [31:0] a, value;
  reg [63:0] z;
  reg [52:0] z_m;
 // reg [7:0] z_r;
  reg [10:0] z_e;
  reg z_s;
  reg guard, round_bit, sticky;

  always @(posedge clk)
  begin
if(!en)
          begin
              s_output_z <= 0;
			    s_complete <= 0;
          end
       else
      begin
    case(state)

      get_a:
      begin
          a <= input_a;
		    s_complete <= 0;
          state <= convert_0;
      end

      convert_0:
      begin
	  //if a is zero 
        if ( a == 0 ) 
		begin
          z_s <= 0;
          z_m <= 0;
          z_e <= -1023;
          state <= pack;
        end 
		//if a<0,convert
		else begin
          value <= a;
          z_s <= 0;
          state <= convert_1;
        end
      end

      convert_1:
      begin
        z_e <= 31;
        z_m <= {value[31:0],20'b0};
        state <= convert_2;
      end

      convert_2:
      begin
        if (!z_m[52]) 
		begin
          z_e <= z_e - 1;
          z_m <= z_m << 1;
   
        end 
		else begin
  
          state <= pack;
        end
      end

     /* round:
      begin
        if (guard && (round_bit || sticky || z_m[0])) begin
          z_m <= z_m + 1;
          if (z_m == 24'hffffff) begin
            z_e <=z_e + 1;
          end
        end
        state <= pack;
      end
*/
      pack:
      begin
        z[51 : 0] <= z_m[51:0];
        z[62 : 52] <= z_e + 1023;
        z[63] <= z_s;
        state <= put_z;
      end

      put_z:
       begin
          s_output_z <= z;   
		  s_complete <= 1;
          state <= get_a;
      end

    endcase

    if (rst == 1) begin
      state <= get_a;
       end

  end
 end
  assign output_z = s_output_z;
   assign complete = s_complete;

endmodule 