module if_i2c_slave #(
  parameter N = 12
)(
  input n_rst,
  input clk,
  input [6:0] my_dev_address,
  
  input [N-1:0] scl_bus,
  inout [N-1:0] sda_bus,
  input [N-1:0] sreset_bus,
  output [N-1:0] sstat_bus,
  
  input [N-1:0] s_rdreq_bus,  // *
  output [7:0] s_dout,
  output [N-1:0] have_msg_bus,  // *
  output [7:0] len,
  
  input [7:0] master_data,
  input [N-1:0] master_ena_bus
);

assign sstat_bus = {N{!ready}} & select_unitary;    // DON'T FORGET TO REMOVE


wire [7:0]  s_din;
wire        s_wrreq;
wire        s_empty;
wire [5:0]  s_used;
wire        s_rdreq = |s_rdreq_bus;
wire ready;
assign len = {2'b0, s_used};

reg [1*N-1:0] select_unitary;
assign have_msg_bus = ~{N{s_empty}} & select_unitary;   // demux of (~s_empty)

wire sda_o, sda_oen;
wire [N-1:0] sda_i_bus;

genvar i;
generate for (i = 0; i < N; i = i + 1)
  begin: wow
  assign sda_bus[i] = (select_unitary[i] & sda_oen & !sda_o) ? 1'b0 : 1'bz;
  assign sda_i_bus[i] = sda_bus[i];
  end
endgenerate


wire scl;                      // mux of scl_bus
wire sda_i;                    // mux of sda_i

muxer_unitary_zero #(
  .WIDTH (1),
  .NUM (N)
)
mux_scl (
  .data_in_bus (scl_bus),
  .ena_in_bus (select_unitary),
  .data_out (scl)
);

muxer_unitary_zero #(
  .WIDTH (1),
  .NUM (N)
)
muxer_sda_i (
  .data_in_bus (sda_i_bus),
  .ena_in_bus (select_unitary),
  .data_out (sda_i)
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


wire [7:0] m_dout;
wire m_rdreq;
wire master_ena = |master_ena_bus;


i2c_slave_teddy i2c_slave_teddy(
  .clk (clk),
  .n_rst (n_rst),
  .my_dev_address (my_dev_address),
  .sda_i (sda_i),
  .sda_o (sda_o),
  .sda_oen (sda_oen),
  .scl (scl),
  .out_data (s_din),
  .out_ena (s_wrreq),
  .ready (ready),
  .master_data (m_dout),
  .master_rdreq (m_rdreq)
);



always@(posedge clk or negedge n_rst)
if(!n_rst)
  select_unitary <= 0;
else
  begin
  if(ready && (~&sda_i_bus))
      select_unitary <= ~sda_i_bus;
  end


fifo_sc fifo_master (
	.aclr  (!n_rst),
	.clock (clk),
	.data  (master_data),
	.rdreq (m_rdreq),
	.wrreq (master_ena),
	.empty (),
	.q     (m_dout),
	.usedw ()
);



endmodule