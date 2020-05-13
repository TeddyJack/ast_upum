module regs_r #(
  parameter N = 2
)(
  input            n_rst,
  input            clk,
  input  [7:0]     master_data,
  input  [N*1-1:0] valid_bus,
  
  input      [N*1-1:0] rdreq_bus,
  output reg [N*1-1:0] have_msg_bus,
  output     [N*8-1:0] slave_data_bus,
  output     [N*8-1:0] len_bus,
  
  input       sbis_functcontrol_stop,
  input [3:0] cmp_o
);

assign len_bus = {N{8'd1}};

// maybe inputs should be registered
assign slave_data_bus[0*8+:8] = {7'b0, sbis_functcontrol_stop};
assign slave_data_bus[1*8+:8] = {4'b0, cmp_o};



always@(posedge clk or negedge n_rst)
  if(!n_rst)
    have_msg_bus <= 0;
  else
    begin
    if(rdreq_bus)   // if any of rdreq_bus[i] == 1'b1
      have_msg_bus <= 0;
    else if(valid_bus) // if any of valid_bus[i] == 1'b1
      have_msg_bus <= valid_bus;
    end



endmodule