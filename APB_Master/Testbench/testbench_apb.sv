module tb();

  reg PCLK;
  reg PRESETn;
  reg PREADY;
  reg [31:0] PRDATA;

  wire [31:0] PADDR;
  wire PSELx, PENABLE;
  wire PWRITE;
  wire [31:0] PWDATA;

  reg start;
  reg write;
  reg [31:0] addr;
  reg [31:0] wdata;

  wire [31:0] rdata;


  APB_MASTER dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PREADY(PREADY),
    .PRDATA(PRDATA),
    .PADDR(PADDR),
    .PSELx(PSELx),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .start(start),
    .write(write),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata)
  );

  always #5 PCLK = ~PCLK;

  // --- SLAVE EMULATION & LOGGING BLOCK ---
  reg [31:0] mem [0:1023];
  reg [1:0] wait_count;

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      PREADY <= 0;
      wait_count <= 0;
      PRDATA <= 0;
    end
    else if (PSELx && PENABLE) begin

      // Simulate 1 cycle wait state
      if (wait_count < 1) begin
        PREADY <= 0;
        wait_count <= wait_count + 1;
      end
      else begin
        PREADY <= 1;
        wait_count <= 0;

        // WRITE Operation
        if (PWRITE) begin
          mem[PADDR[11:2]] <= PWDATA;
          $display("TIME=%0t | WRITE | ADDR=%h | DATA=%h",
                    $time, PADDR, PWDATA);
        end

        // READ Operation
        else begin
          PRDATA <= mem[PADDR[11:2]];
          $display("TIME=%0t | READ  | ADDR=%h | DATA=%h",
                    $time, PADDR, mem[PADDR[11:2]]);
        end
      end
    end
    else begin
      PREADY <= 0;
      wait_count <= 0;
    end
  end


  initial begin

    $dumpfile("APB.vcd");
    $dumpvars(0, tb);

    // Initial values
    PCLK    = 0;
    PRESETn = 0;

    start = 0;
    write = 0;
    addr  = 0;
    wdata = 0;

    // Reset
    #25 PRESETn = 1;

    // =========================================================
    // WRITE TRANSACTION 1
    // Address : 0x10001000
    // Data    : 0x12345678
    // =========================================================
    @(posedge PCLK);
    addr  = 32'h1000_1000;
    wdata = 32'h1234_5678;
    write = 1;
    start = 1;

    @(posedge PCLK); // SETUP
    @(posedge PCLK); // ACCESS
    wait(PREADY);

    @(posedge PCLK);
    start = 0;

    #40;

    // =========================================================
    // WRITE TRANSACTION 2
    // Address : 0x11001101
    // Data    : 0x43215763
    // =========================================================
    @(posedge PCLK);
    addr  = 32'h1100_1101;
    wdata = 32'h4321_5763;
    write = 1;
    start = 1;

    @(posedge PCLK); // SETUP
    @(posedge PCLK); // ACCESS
    wait(PREADY);

    @(posedge PCLK);
    start = 0;

    #40;

    // =========================================================
    // READ TRANSACTION
    // Address : 0x10001000
    // =========================================================
    @(posedge PCLK);
    addr  = 32'h1000_1000;
    write = 0;
    start = 1;

    @(posedge PCLK); // SETUP
    @(posedge PCLK); // ACCESS
    wait(PREADY);

    @(posedge PCLK);
    start = 0;

    #100;

    $finish;

  end

endmodule
