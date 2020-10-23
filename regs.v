module regs #(
  parameter N = 4+21+1+2 // inputs + outputs + inouts + special
)(
  input                n_rst,
  input                clk,
  input      [7:0]     master_data,
  input      [N*1-1:0] valid_bus,
  input      [N*1-1:0] rdreq_bus,
  output     [N*1-1:0] have_msg_bus,
  
  output     [7:0] len,
  output     [7:0] slave_data,
  // inputs
  input       sbis_functcontrol_stop,
  input [3:0] cmp_o,
  input       gpio_o_144_159,
  input       gpio_o_128_143,
  input       gpio_o_112_127,
  input       gpio_o_96_111,
  input       gpio_o_80_95,
  input       gpio_o_64_79,
  input       gpio_o_48_63,
  input       gpio_o_32_47,
  input       gpio_o_16_31,
  input       gpio_o_0_15,
  // outputs
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
  output reg       clk_gen_control,
  output reg       csa,
  output reg       funct_en,
  output reg [3:0] a_gpio,
  output reg       load_pdr_0,
  output reg       load_pdr_5v5_1,
  output reg       load_pdr_5v0_1,
  output reg       load_pdr_4v5_1,
  output reg       i2c_speed,
  output reg       rstn,
  // inouts
  inout gpio_io_32_49,
  inout gpio_io_16_31,
  inout gpio_io_0_15
  // special are not ports
  
);

wire [N*8-1:0] slave_data_bus;
reg [2:0] gpio_z_state;
reg [2:0] reg_io_0_49;
assign gpio_io_32_49 = gpio_z_state[2] ? 1'bz : reg_io_0_49[2];
assign gpio_io_16_31 = gpio_z_state[1] ? 1'bz : reg_io_0_49[1];
assign gpio_io_0_15 = gpio_z_state[0] ? 1'bz : reg_io_0_49[0];



assign len = 8'd1;

// inputs
assign slave_data_bus[0*8+:8] =  {7'b0, sbis_functcontrol_stop};
assign slave_data_bus[1*8+:8] =  {4'b0, cmp_o};
assign slave_data_bus[2*8+:8] =  {gpio_o_112_127, gpio_o_96_111,
                                  gpio_o_80_95, gpio_o_64_79,
                                  gpio_o_48_63, gpio_o_32_47,
                                  gpio_o_16_31, gpio_o_0_15};
assign slave_data_bus[3*8+:8] =  {6'b0, gpio_o_144_159, gpio_o_128_143};
// outputs                       
assign slave_data_bus[4*8+:8] =  {7'b0, rst_power};
assign slave_data_bus[5*8+:8] =  {7'b0, off_vdd};
assign slave_data_bus[6*8+:8] =  {7'b0, off_dvdd};
assign slave_data_bus[7*8+:8] =  {7'b0, off_avdd};
assign slave_data_bus[8*8+:8] =  {7'b0, off_limit_input};
assign slave_data_bus[9*8+:8] =  {7'b0, rst_cmp_oa};
assign slave_data_bus[10*8+:8] = {7'b0, funct_en_1};
assign slave_data_bus[11*8+:8] = {1'b0, addr};
assign slave_data_bus[12*8+:8] = {7'b0, nce_fl1};
assign slave_data_bus[13*8+:8] = {7'b0, nce_fl2};
assign slave_data_bus[14*8+:8] = {7'b0, en_gpio_fl1};
assign slave_data_bus[15*8+:8] = {6'b0, cpu_cfg};
assign slave_data_bus[16*8+:8] = {7'b0, clk_gen_control};
assign slave_data_bus[17*8+:8] = {7'b0, csa};
assign slave_data_bus[18*8+:8] = {7'b0, funct_en};
assign slave_data_bus[19*8+:8] = {4'b0, a_gpio};
assign slave_data_bus[20*8+:8] = {7'b0, load_pdr_0};
assign slave_data_bus[21*8+:8] = {7'b0, load_pdr_5v5_1};
assign slave_data_bus[22*8+:8] = {7'b0, load_pdr_5v0_1};
assign slave_data_bus[23*8+:8] = {7'b0, load_pdr_4v5_1};
// inouts
assign slave_data_bus[24*8+:8] = {5'b0, gpio_io_32_49, gpio_io_16_31, gpio_io_0_15};
// special
assign slave_data_bus[25*8+:8] = {5'b0, gpio_z_state};
assign slave_data_bus[26*8+:8] = {7'b0, rstn};
assign slave_data_bus[27*8+:8] = {7'b0, i2c_speed};




always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    begin
    rst_power       <= 1'b1;
    off_vdd         <= 1'b1;
    off_dvdd        <= 1'b1;
    off_avdd        <= 1'b1;
    off_limit_input <= 1'b1;
    rst_cmp_oa      <= 1'b1;
    funct_en_1      <= 1'b0;
    addr            <= 7'h7F;
    nce_fl1         <= 1'b0;
    nce_fl2         <= 1'b0;
    en_gpio_fl1     <= 1'b0;
    cpu_cfg         <= 1'b0;
    clk_gen_control <= 1'b0;
    csa             <= 1'b0;
    funct_en        <= 1'b1;
    a_gpio          <= 4'd0;
    load_pdr_0      <= 1'b0;
    load_pdr_5v5_1  <= 1'b0;
    load_pdr_5v0_1  <= 1'b0;
    load_pdr_4v5_1  <= 1'b0;
    reg_io_0_49     <= 3'b0;
    gpio_z_state    <= 3'b111;
    i2c_speed       <= 1'b1;
    rstn            <= 1'b0;
    end
  else
    begin
    // valid_bus[0]... [3] are missing because they are read only
    if (valid_bus[4])   rst_power       <= master_data[0];
    if (valid_bus[5])   off_vdd         <= master_data[0];
    if (valid_bus[6])   off_dvdd        <= master_data[0];
    if (valid_bus[7])   off_avdd        <= master_data[0];
    if (valid_bus[8])   off_limit_input <= master_data[0];
    if (valid_bus[9])   rst_cmp_oa      <= master_data[0];
    if (valid_bus[10])  funct_en_1      <= master_data[0];
    if (valid_bus[11])  addr            <= master_data[6:0];
    if (valid_bus[12])  nce_fl1         <= master_data[0];
    if (valid_bus[13])  nce_fl2         <= master_data[0];
    if (valid_bus[14])  en_gpio_fl1     <= master_data[0];
    if (valid_bus[15])  cpu_cfg         <= master_data[1:0];
    if (valid_bus[16])  clk_gen_control <= master_data[0];
    if (valid_bus[17])  csa             <= master_data[0];
    if (valid_bus[18])  funct_en        <= master_data[0];
    if (valid_bus[19])  a_gpio          <= master_data[3:0];
    if (valid_bus[20])  load_pdr_0      <= master_data[0];
    if (valid_bus[21])  load_pdr_5v5_1  <= master_data[0];
    if (valid_bus[22])  load_pdr_5v0_1  <= master_data[0];
    if (valid_bus[23])  load_pdr_4v5_1  <= master_data[0];
    if (valid_bus[24])  reg_io_0_49     <= master_data[2:0];
    if (valid_bus[25])  gpio_z_state    <= master_data[2:0];
    if (valid_bus[26])  rstn            <= master_data[0];
    if (valid_bus[27])  i2c_speed       <= master_data[0];
    end


reg [4:0] have_msg_regs;                        // because we have 4 READ-addresses + 1 RW-address
assign have_msg_bus[27:25] = 0;                 // these addresses are WRITE
assign have_msg_bus[24] = have_msg_regs[4];     // this address is READ / WRITE
assign have_msg_bus[23:4] = 0;                  // these addresses are WRITE
assign have_msg_bus[3:0] = have_msg_regs[3:0];  // these addresses are READ
wire [4:0] rdreq_bus_inner = {rdreq_bus[24], rdreq_bus[3:0]};
wire [4:0] valid_bus_inner = {valid_bus[24], valid_bus[3:0]};


always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    have_msg_regs <= 0;
  else
    begin
    if (rdreq_bus_inner)               // if any of rdreq_bus[i] == 1'b1
      have_msg_regs <= 0;
    else if (valid_bus_inner)           // if any of valid_bus[i] == 1'b1
      have_msg_regs <= valid_bus_inner;
    end



muxer_unitary #(
  .WIDTH (8),
  .NUM (N)
)
muxer_unitary (
  .data_in_bus (slave_data_bus),
  .ena_in_bus (have_msg_bus),
  .data_out (slave_data)
);



endmodule