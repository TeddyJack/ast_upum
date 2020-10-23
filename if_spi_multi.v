module if_spi_multi #(
  parameter       N_SLAVES = 3,
  parameter [0:0] CPOL = 0,
  parameter [0:0] CPHA = 0,
  parameter [7:0] BYTES_PER_FRAME = 2,
  parameter [0:0] BIDIR = 0,
  parameter [7:0] SWAP_DIR_BIT_NUM = 7,
  parameter [0:0] SCLK_CONST = 0
)(
  input                     n_rst,
  input                     sys_clk,
  input                     sclk_common,

  output  [1*N_SLAVES-1:0]  n_cs_bus,
  output                    sclk,
  output                    mosi,
  input                     miso,
  input                     sdio,
  output                    io_update,
  
  input   [7:0]             m_din,
  input   [1*N_SLAVES-1:0]  m_wrreq_bus,  // reduce to one
  
  input   [1*N_SLAVES-1:0]  s_rdreq_bus,  // reduce to one
  output  [7:0]  s_dout,   // replicate to N
  output  [1*N_SLAVES-1:0]  have_msg_bus, // 
  output  [7:0]  len       // replicate to N
);


wire [7:0] s_din;
wire s_wrreq;
wire s_empty;
wire s_rdreq = |s_rdreq_bus;
// wire [7:0] m_din           // declared in ports
wire m_wrreq = |m_wrreq_bus;
wire m_empty;
wire [7:0] m_dout;
wire m_rdreq;
reg [1*N_SLAVES-1:0] select_unitary;
assign have_msg_bus = ~{N_SLAVES{s_empty}} & select_unitary;
wire n_cs;
assign n_cs_bus = {N_SLAVES{n_cs}} | ~select_unitary;



spi_master_byte #(
  .CPOL             (CPOL),
  .CPHA             (CPHA),
  .BYTES_PER_FRAME  (BYTES_PER_FRAME),
  .BIDIR            (BIDIR),
  .SWAP_DIR_BIT_NUM (SWAP_DIR_BIT_NUM),
  .SCLK_CONST       (SCLK_CONST)
)
spi_master_inst (
  .n_rst        (n_rst),
  .sys_clk      (sclk_common),
  .sclk         (sclk),
  .mosi         (mosi),
  .miso         (miso),
  .n_cs         (n_cs),
  .sdio         (sdio),
  .io_update    (io_update),
  .master_data  (m_dout),
  .master_empty (m_empty),
  .master_rdreq (m_rdreq),
  .miso_reg     (s_din),
  .slave_wrreq  (s_wrreq)
);



always@(posedge sys_clk or negedge n_rst)
if(!n_rst)
  select_unitary <= 0;
else
  begin
  if(m_wrreq)
      select_unitary <= m_wrreq_bus;
  end



fifo_spi fifo_master (
  .aclr     (!n_rst),
  .data     (m_din),
  .rdclk    (sclk_common),
  .rdreq    (m_rdreq),
  .wrclk    (sys_clk),
  .wrreq    (m_wrreq),
  .q        (m_dout),
  .rdempty  (m_empty)
);



fifo_spi fifo_slave (
  .aclr     (!n_rst),
  .data     (s_din),
  .rdclk    (sys_clk),
  .rdreq    (s_rdreq),
  .wrclk    (sclk_common),
  .wrreq    (s_wrreq),
  .q        (s_dout),
  .rdempty  (s_empty),
  .rdusedw  (len)
);



endmodule