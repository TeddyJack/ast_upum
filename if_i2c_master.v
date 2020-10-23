module if_i2c_master #(
  parameter N = 12
)(
  input n_rst,
  input clk,
  
  input i2c_speed,
  output [N-1:0] scl_bus,
  inout [N-1:0] sda_bus,
  output [N-1:0] sreset_bus,
  input [N-1:0] sstat_bus,
  
  input [7:0] m_din,
  input [N-1:0] m_wrreq_bus,  // *
  
  input [N-1:0] s_rdreq_bus,  // *
  output [7:0] s_dout,
  output [N-1:0] have_msg_bus,  // *
  output [7:0] len
);

assign sreset_bus = m_wrreq_bus;  // DON'T FORGET TO REMOVE


wire        m_empty;
wire [7:0]  m_dout;
wire        m_rdreq;
wire [5:0]  m_used;
wire [7:0]  s_din;
wire        s_wrreq;
wire        s_empty;
wire [5:0]  s_used;
wire ready;
assign len = {2'b0, s_used};

wire m_wrreq = |m_wrreq_bus;
wire s_rdreq = |s_rdreq_bus;
reg [1*N-1:0] select_unitary;
assign have_msg_bus = ~{N{s_empty}} & select_unitary;   // demux of (~s_empty)

wire scl;
assign scl_bus = {N{scl}} | ~select_unitary; // demux of scl, but active "0"
wire sda_o;
wire sda_oen;
wire [N-1:0] sda_o_bus = {N{sda_o}} | ~select_unitary;    // demux of sda_o, but active "0"
wire [N-1:0] sda_oen_bus = {N{sda_oen}} & select_unitary; // demux of sda_oen
wire [N-1:0] sda_i_bus;
genvar i;
generate for (i = 0; i < 12; i = i + 1)
  begin: wow
  assign sda_bus[i] = sda_oen_bus[i] ? sda_o_bus[i] : 1'bz;
  assign sda_i_bus[i] = sda_bus[i];
  end
endgenerate
//assign sda_bus = sda_oen_bus ? sda_o_bus : {N{1'bz}}; // WRONG

wire sda_i;                      // mux of sda_i

muxer_unitary #(
  .WIDTH (1),
  .NUM (N)
)
muxer_unitary (
  .data_in_bus (sda_i_bus),
  .ena_in_bus (select_unitary),
  .data_out (sda_i)
);










reg [7:0] num_bytes_data;
reg [7:0] num_bytes_address;
reg [6:0] dev_addr;
reg r_nw;
reg start;
reg [2:0] state;
reg ctrl_rdreq;
localparam IDLE = 0;
localparam DEV_ADDR_RNW = 1;
localparam LEN_ADDR = 2;
localparam LEN_DATA = 3;
localparam OPERATE = 4;





fifo_sc fifo_master (
  .aclr  (!n_rst),
	.clock (clk),
	.data  (m_din),
  .rdreq (m_rdreq | ctrl_rdreq),
	.wrreq (m_wrreq),
	.empty (m_empty),
	.q     (m_dout),
	.usedw (m_used)
);




fifo_sc fifo_slave (
	.aclr  (!n_rst),
	.clock (clk),
	.data  (s_din),
	.rdreq (s_rdreq),
	.wrreq (s_wrreq),
	.empty (s_empty),
	.q     (s_dout),
	.usedw (s_used)
);





i2c_master_teddy i2c_master_teddy (
  .CLK_DIV (i2c_speed ? 15'd222 : 15'd888),  // CLK_DIV = 8 * F_CLK / 9 / BAUDRATE
  .clk (clk),
  .n_rst (n_rst),
  .start (start),
  .r_nw (r_nw),
  .dev_addr (dev_addr),
  .data_in (m_dout),
  .num_bytes_data (num_bytes_data),
  .num_bytes_address (num_bytes_address),
  .ready (ready),
  .rd_req (m_rdreq),
  .sda_i (sda_i),
  .sda_o (sda_o),
  .sda_oen (sda_oen),
  .scl_o (scl),
  .out_data (s_din),
  .out_ena (s_wrreq)
);






// message parsing and control of i2c_master_teddy
always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    begin
    num_bytes_data <= 0;
    num_bytes_address <= 0;
    dev_addr <= 0;
    r_nw <= 0;
    start <= 0;
    state <= IDLE;
    ctrl_rdreq <= 0;
    end
  else
    case (state)
    IDLE:
      if (!m_empty)
        begin
        state <= DEV_ADDR_RNW;
        ctrl_rdreq <= 1;
        end
    DEV_ADDR_RNW:
      begin
      dev_addr <= m_dout[7:1];
      r_nw <= m_dout[0];
      state <= LEN_ADDR;
      end
    LEN_ADDR:
      begin
      num_bytes_address <= m_dout;
      state <= LEN_DATA;
      ctrl_rdreq <= 0;
      end
    LEN_DATA:
      begin
      if (r_nw)
        num_bytes_data <= m_dout;
      else
        num_bytes_data <= num_bytes_address + m_dout;
      state <= OPERATE;
      start <= 1;
      end
    OPERATE:
      begin
      start <= 0;
      if (ready & !start) // (& !start) to skip first tact, when "ready" hasn't gone to 0 yet
        state <= IDLE;
      end  
    endcase





always@(posedge clk or negedge n_rst)
if(!n_rst)
  select_unitary <= 0;
else
  begin
  if(m_wrreq)
      select_unitary <= m_wrreq_bus;
  end


endmodule