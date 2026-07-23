module fifo(
  input clk,reset,
  input[7:0] d_in,
  output reg[7:0] d_out,
  input wr_en, rd_en,
  output reg full, empty, half_full, almost_full, almost_empty
);
  reg[2:0] wr_ptr, rd_ptr;
  reg[7:0]M[0:7];
  integer i;
  reg[3:0] count;
  
  always@(posedge clk or posedge reset) begin
    if(reset) begin
      rd_ptr<=0;
      wr_ptr<=0;
      count<=0;
      d_out<=0;
      for(i=0;i<=7;i=i+1) begin
      M[i]=8'h00;
     end 
    end
  end
  
   always@(posedge clk) begin
    if( wr_en && !rd_en && !full)begin
      M[wr_ptr]<=d_in;
      wr_ptr<=wr_ptr+1;
      count<=count+1;
    end
   end 
   always @(posedge clk) begin
    if (rd_en && !wr_en && !empty) begin
       d_out <= M[rd_ptr];
       rd_ptr <= rd_ptr + 1;
       count <= count - 1;
    end
   end  
  
  always@(*) begin
    empty = 0;
    almost_empty = 0;
    half_full = 0;
    almost_full = 0;
    full = 0;
    case(count)
        0: empty=1;
      
        1: almost_empty=1;
      
        4: half_full=1;
    
        7: almost_full=1;
     
        8: full=1;
      
    endcase
  end
  
endmodule  
      




