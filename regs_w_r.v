module regs_w_r #(
  parameter N = 21
)(
  input            n_rst,
  input            clk,
  input  [7:0]     master_data,
  input  [N*1-1:0] valid_bus,
  
  input      [N*1-1:0] rdreq_bus,
  output reg [N*1-1:0] have_msg_bus,
  output     [N*8-1:0] slave_data_bus,
  output     [N*8-1:0] len_bus,
  
  output reg       rst_power,
  output reg       off_vdd,
  output reg       off_dvdd,
  output reg       off_avdd,
  output reg       off_limit_input,
  output reg       rst_cmp_oa,
  output reg       funct_en_1,
  output reg [6:0] addr,
  output reg       nce_fl1,
  output reg       nce_fl2,
  output reg       en_gpio_fl1,
  output reg [1:0] cpu_cfg,
  output reg       clk_a,
  output reg       clk_gen_control,
  output reg       csa,
  output reg       funct_en,
  output reg [3:0] a_gpio,
  output reg       load_pdr_0,
  output reg       load_pdr_5v5_1,
  output reg       load_pdr_5v0_1,
  output reg       load_pdr_4v5_1
);

assign len_bus = {N{8'd1}};
assign slave_data_bus[0*8+:8] = {7'b0, rst_power};
assign slave_data_bus[1*8+:8] = {7'b0, off_vdd};
assign slave_data_bus[2*8+:8] = {7'b0, off_dvdd};
assign slave_data_bus[3*8+:8] = {7'b0, off_avdd};
assign slave_data_bus[4*8+:8] = {7'b0, off_limit_input};
assign slave_data_bus[5*8+:8] = {7'b0, rst_cmp_oa};
assign slave_data_bus[6*8+:8] = {7'b0, funct_en_1};
assign slave_data_bus[7*8+:8] = {1'b0, addr};
assign slave_data_bus[8*8+:8] = {7'b0, nce_fl1};
assign slave_data_bus[9*8+:8] = {7'b0, nce_fl2};
assign slave_data_bus[10*8+:8] = {7'b0, en_gpio_fl1};
assign slave_data_bus[11*8+:8] = {6'b0, cpu_cfg};
assign slave_data_bus[12*8+:8] = {7'b0, clk_a};
assign slave_data_bus[13*8+:8] = {7'b0, clk_gen_control};
assign slave_data_bus[14*8+:8] = {7'b0, csa};
assign slave_data_bus[15*8+:8] = {7'b0, funct_en};
assign slave_data_bus[16*8+:8] = {4'b0, a_gpio};
assign slave_data_bus[17*8+:8] = {7'b0, load_pdr_0};
assign slave_data_bus[18*8+:8] = {7'b0, load_pdr_5v5_1};
assign slave_data_bus[19*8+:8] = {7'b0, load_pdr_5v0_1};
assign slave_data_bus[20*8+:8] = {7'b0, load_pdr_4v5_1};

always@(posedge clk or negedge n_rst)
  if(!n_rst)
    begin
    rst_power       <= 1'b0;
    off_vdd         <= 1'b0;
    off_dvdd        <= 1'b0;
    off_avdd        <= 1'b0;
    off_limit_input <= 1'b0;
    rst_cmp_oa      <= 1'b0;
    funct_en_1      <= 1'b0;
    addr            <= 7'h7F;
    nce_fl1         <= 1'b0;
    nce_fl2         <= 1'b0;
    en_gpio_fl1     <= 1'b0;
    cpu_cfg         <= 1'b0;
    clk_a           <= 1'b0;
    clk_gen_control <= 1'b0;
    csa             <= 1'b0;
    funct_en        <= 1'b0;
    a_gpio          <= 4'd0;
    load_pdr_0      <= 1'b0;
    load_pdr_5v5_1  <= 1'b0;
    load_pdr_5v0_1  <= 1'b0;
    load_pdr_4v5_1  <= 1'b0;
    end
  else
    begin
    if (valid_bus[0])   rst_power       <= master_data[0];
    if (valid_bus[1])   off_vdd         <= master_data[0];
    if (valid_bus[2])   off_dvdd        <= master_data[0];
    if (valid_bus[3])   off_avdd        <= master_data[0];
    if (valid_bus[4])   off_limit_input <= master_data[0];
    if (valid_bus[5])   rst_cmp_oa      <= master_data[0];
    if (valid_bus[6])   funct_en_1      <= master_data[0];
    if (valid_bus[7])   addr            <= master_data[6:0];
    if (valid_bus[8])   nce_fl1         <= master_data[0];
    if (valid_bus[9])   nce_fl2         <= master_data[0];
    if (valid_bus[10])  en_gpio_fl1     <= master_data[0];
    if (valid_bus[11])  cpu_cfg         <= master_data[1:0];
    if (valid_bus[12])  clk_a           <= master_data[0];
    if (valid_bus[13])  clk_gen_control <= master_data[0];
    if (valid_bus[14])  csa             <= master_data[0];
    if (valid_bus[15])  funct_en        <= master_data[0];
    if (valid_bus[16])  a_gpio          <= master_data[3:0];
    if (valid_bus[17])  load_pdr_0      <= master_data[0];
    if (valid_bus[18])  load_pdr_5v5_1  <= master_data[0];
    if (valid_bus[19])  load_pdr_5v0_1  <= master_data[0];
    if (valid_bus[20])  load_pdr_4v5_1  <= master_data[0];
    end


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