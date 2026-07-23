module APB_MASTER(
  input PCLK,
  input PRESETn,
  input PREADY,
  input [31:0] PRDATA,

  output reg [31:0] PADDR,
  output reg PSELx, PENABLE,
  output reg PWRITE,
  output reg [31:0] PWDATA,

  input start,
  input write,
  input [31:0] addr,
  input [31:0] wdata,
  output reg [31:0] rdata
);

  reg [1:0] state;
  parameter IDLE=2'b00, SETUP=2'b01, ACCESS=2'b10;

  reg [31:0] addr_reg, wdata_reg;
  reg write_reg;

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      state   <= IDLE;
      PSELx   <= 0;
      PENABLE <= 0;
      PWRITE  <= 0;
      PADDR   <= 0;
      PWDATA  <= 0;
      rdata   <= 0;
    end
    else begin
      case (state)

        IDLE: begin
          PSELx   <= 0;
          PENABLE <= 0;

          if (start) begin
            addr_reg  <= addr;
            wdata_reg <= wdata;
            write_reg <= write;
            state     <= SETUP;
          end
        end

        SETUP: begin
          PSELx   <= 1;
          PENABLE <= 0;

          PADDR   <= addr_reg;
          PWDATA  <= wdata_reg;
          PWRITE  <= write_reg;

          state   <= ACCESS;
        end

        ACCESS: begin
          PSELx   <= 1;
          PENABLE <= 1;

          if (PREADY) begin
            if (!PWRITE)
              rdata <= PRDATA;

            if (start) begin
              addr_reg  <= addr;
              wdata_reg <= wdata;
              write_reg <= write;
              state     <= SETUP;
            end else begin
              state <= IDLE;
            end
          end
        end

      endcase
    end
  end

endmodule
