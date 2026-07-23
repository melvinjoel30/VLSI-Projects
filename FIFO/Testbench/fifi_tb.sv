module tb;
  reg clk,reset;
  reg [7:0] d_in;
  reg wr_en, rd_en;
  wire [7:0] d_out;
  wire full, empty, half_full, almost_full, almost_empty;

  fifo dut (
    .clk(clk),
    .reset(reset),
    .d_in(d_in),
    .d_out(d_out),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .full(full),
    .empty(empty),
    .half_full(half_full),
    .almost_full(almost_full),
    .almost_empty(almost_empty)
  );
  
  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars();
  end

  always #5 clk = ~clk;

  integer i;

  initial begin
    clk=0;
    reset=1;
    wr_en=0;
    rd_en=0;
    d_in=0;

    #10 reset=0;

    $display("----Write Phase----");

    for(i=0;i<8;i=i+1) begin
      @(posedge clk);
      wr_en = 1;
      rd_en = 0;
      d_in  = i+1;
      #1;
      
      $display("T=%0t | wr=%b rd=%b | din=%0d dout=%0d | full=%b empty=%b half_full=%b a_full=%b a_empty=%b",
               $time, wr_en, rd_en, d_in, d_out, full, empty, half_full, almost_full, almost_empty);
    end

    @(posedge clk);
   
    wr_en = 0;

    $display("----Read Phase----");
    for(i=0;i<8;i=i+1) begin
      @(posedge clk);
      wr_en = 0;
      rd_en = 1;
      
      $display("T=%0t | wr=%b rd=%b | dout=%0d | full=%b empty=%b half_full=%b a_full=%b a_empty=%b",
               $time, wr_en, rd_en, d_out, full, empty, half_full, almost_full, almost_empty);
    end
  end

  initial #300 $finish;

endmodule
  
