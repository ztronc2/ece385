/*---------------------------------------------------------------------------
  --      lab9.sv                                                          --
  --      Christine Chen                                                   --
  --      10/23/2013                                                       --
  --                                                                       --
  --      For use with ECE 298 Experiment 9                                --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/
// Top-level module that integrates the Nios II system with the rest of the hardware

module lab9(  input               CLOCK_50, 
              input        [1:0]  KEY,
              output logic [7:0]  LEDG,
              output logic [17:0] LEDR,
              output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
              output logic [12:0] DRAM_ADDR,
              output logic [1:0]  DRAM_BA,
              output logic        DRAM_CAS_N,
              output logic        DRAM_CKE,
              output logic        DRAM_CS_N,
              inout  wire  [31:0] DRAM_DQ,
              output logic [3:0]  DRAM_DQM,
              output logic        DRAM_RAS_N,
              output logic        DRAM_WE_N,
              output logic        DRAM_CLK
              );
                  
logic  [1:0] to_sw_sig;
logic  [1:0] to_hw_sig;
logic  [7:0] to_sw_port;
logic  [7:0] to_hw_port;
logic  [127:0] msg_en;
logic  [127:0] key;
logic  [127:0] msg_de;
logic          io_ready;
logic          aes_ready;

// For debugging purpose
assign LEDR[7:0] = {to_hw_port[7:0]};
assign LEDG[3:0] = {to_sw_sig, to_hw_sig};

// You need to make sure the port names match the codes generated by Qsys.
nios_system NiosII ( .clk_clk(CLOCK_50), 
                     .reset_reset_n(KEY[0]), 
                     .to_sw_sig_export(to_sw_sig), 
                     .to_hw_sig_export(to_hw_sig),
                     .to_sw_port_export(to_sw_port),
                     .to_hw_port_export(to_hw_port),
                     .sdram_wire_addr(DRAM_ADDR),
                     .sdram_wire_ba(DRAM_BA),
                     .sdram_wire_cas_n(DRAM_CAS_N),
                     .sdram_wire_cke(DRAM_CKE),
                     .sdram_wire_cs_n(DRAM_CS_N),
                     .sdram_wire_dq(DRAM_DQ),
                     .sdram_wire_dqm(DRAM_DQM),
                     .sdram_wire_ras_n(DRAM_RAS_N),
                     .sdram_wire_we_n(DRAM_WE_N),
                     .sdram_wire_clk(DRAM_CLK)
                     );
                         
io_module io_module0 (.clk(CLOCK_50),
                      .reset_n(KEY[1]),
                      .to_sw_sig(to_sw_sig),
                      .to_sw_port(to_sw_port),
                      .to_hw_sig(to_hw_sig),
                      .to_hw_port(to_hw_port),
                      .msg_en(msg_en),
                      .key(key),
                      .msg_de(msg_de),
                      .io_ready(io_ready),
                      .aes_ready(aes_ready)
);


aes_controller aes_controller0 (.clk(CLOCK_50),
                                .reset_n(KEY[1]),
                                .msg_en(msg_en),
                                .key(key),
                                .msg_de(msg_de),
                                .io_ready(io_ready),
                                .aes_ready(aes_ready)
);
                
// Displays the first 4 and the last 4 digits of the received message
HexDriver Hex0 (.In0(msg_en[3:0]),
                .Out0(HEX0) );
HexDriver Hex1 (.In0(msg_en[7:4]),
                .Out0(HEX1) );
HexDriver Hex2 (.In0(msg_en[11:8]),
                .Out0(HEX2) );
HexDriver Hex3 (.In0(msg_en[15:12]),
                .Out0(HEX3) );
HexDriver Hex4 (.In0(msg_en[115:112]),
                .Out0(HEX4) );
HexDriver Hex5 (.In0(msg_en[119:116]),
                .Out0(HEX5) );
HexDriver Hex6 (.In0(msg_en[123:120]),
                .Out0(HEX6) );
HexDriver Hex7 (.In0(msg_en[127:124]),
                .Out0(HEX7) );
endmodule
