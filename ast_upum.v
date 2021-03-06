`include "defines.v"

module ast_upum (
  input clk_100,
  // UART
  input rx,
  output tx,/*
  // sdram
  inout [15:0] sdram_dq,
  output sdram_clk,
  output sdram_cke,
  output [12:0] sdram_a,
  output sdram_we,
  output sdram_cas,
  output sdram_cs,
  output [1:0] sdram_ba,*/
  // potentiometers on power board
  output rst_power, // resets potentiometer
  output sclk_power,
  output din_power,
  output sync_vdd,
  output sync_dvdd,
  output sync_avdd,
  output sync_limit_input,
  output off_vdd,
  output off_dvdd,
  output off_avdd,
  output off_limit_input,
  // potentiometers (cmp = comparator, oa = op amp)
  output rst_cmp_oa,
  output sclk_cmp_oa,
  output din_cmp_oa,
  output sync_cmp_a,
  output sync_cmp_b,
  output sync_oa_0,
  output sync_oa_1,
  // adc power
  output pwr_adc_sclk,
  output pwr_adc_din,
  input pwr_adc_dout,
  output pwr_adc_cs,
  // adcs 1-3
  output adc_sclk,
  output adc_din,
  input adc_dout,
  output adc_cs_1,
  output adc_cs_2,
  output adc_cs_3,
  //
  input sbis_functcontrol_stop, // if any of voltages is too high
  // I2C slaves and masters
  output funct_en_1,  // enables I2C repeaters
  output [6:0] addr,  // goes to upum, I2C address
  inout [3:0] s_scl,
  inout [3:0] s_sda,
  output [3:0] s_sreset,
  input [3:0] s_sstat,
  inout [11:0] m_scl,
  inout [11:0] m_sda,
  input [11:0] m_sreset,
  output [11:0] m_sstat,
  // control flash memory
  output nce_fl1,
  output nce_fl2,
  output en_gpio_fl1,
  
  output [1:0] cpu_cfg, // goes to upum
  
  input o_clk,  // clock generated by upum
  output clk_a, // clock goes to upum, make it 10 MHz
  output clk_gen_control,
  output csa,  //
  output rst_n,
  
  output funct_en,  // enables func control, disables load switches
  output [3:0] a_gpio,  // address of multiplexer for gpio
  output gpio_io_32_49,
  output gpio_io_16_31,
  output gpio_io_0_15,
  input gpio_o_144_159,
  input gpio_o_128_143,
  input gpio_o_112_127,
  input gpio_o_96_111,
  input gpio_o_80_95,
  input gpio_o_64_79,
  input gpio_o_48_63,
  input gpio_o_32_47,
  input gpio_o_16_31,
  input gpio_o_0_15,
  
  // ???????????????????? ???????????????? ?? gpio
  output load_pdr_0,
  output load_pdr_5v5_1,
  output load_pdr_5v0_1,
  output load_pdr_4v5_1
  // debug outputs
  //output [7:0] my_tx_data,
  //output my_tx_valid,
  //output reg stp_clk
);

localparam PRESCALE = `SYS_CLK * 1000000 / (`BAUDRATE * 8);	// = fclk / (baud * 8)
wire sys_clk/* = clk_100*/;
wire [7:0] rx_data;
wire rx_valid;
wire rx_ready;
wire [7:0] tx_data;
wire tx_valid;
wire tx_ready;
wire [7:0] master_data;
wire [1*`N_SRC-1:0] valid_bus;
wire [1*`N_SRC-1:0] have_msg_bus;
wire [8*`N_INPUTS-1:0] slave_data_bus;
wire [8*`N_INPUTS-1:0] len_bus;
wire [1*`N_SRC-1:0] rdreq_bus;
wire n_rst_ext;
wire pll_locked;
wire n_rst = pll_locked & n_rst_ext;
wire sclk_common;
assign clk_a = sclk_common & clk_enable;
wire i2c_speed;
wire clk_enable;




pll_upum pll_upum (
	.inclk0 (clk_100),
	.c0 (sclk_common),
  .c1 (sys_clk),
  .locked (pll_locked)
);



cmd_decoder cmd_decoder (
  .n_rst     (n_rst),
  .clk       (sys_clk),
  .rx_data   (rx_data),
  .rx_valid  (rx_valid),
  .rx_ready  (rx_ready),
  .q         (master_data),
  .valid_bus (valid_bus)
);



cmd_encoder cmd_encoder (
  .n_rst        (n_rst),
  .clk          (sys_clk),
  .have_msg_bus (have_msg_bus),
  .data_bus     (slave_data_bus),
  .len_bus      (len_bus),
  .rdreq_bus    (rdreq_bus),
  .tx_data      (tx_data),
  .tx_valid     (tx_valid),
  .tx_ready     (tx_ready)
);



uart uart (
  .clk                (sys_clk),
  .rst                (!n_rst),
  // AXI input
  .input_axis_tdata   (tx_data),    // I make it
  .input_axis_tvalid  (tx_valid),   // I make it
  .input_axis_tready  (tx_ready),
  // AXI output
  .output_axis_tdata  (rx_data),
  .output_axis_tvalid (rx_valid),
  .output_axis_tready (rx_ready),   // I make it
  // UART interface
  .rxd                (rx),
  .txd                (tx),
  // Configuration
  .prescale           (PRESCALE[15:0])
);



// address 0x00
keep_alive keep_alive (
  .n_rst    (n_rst),
  .clk      (sys_clk),
  .data     (master_data),
  .ena      (valid_bus[0]),
  .have_msg (have_msg_bus[0]),
  .rdreq    (rdreq_bus[0]),
  .data_out (slave_data_bus[0*8+:8]),
  .len      (len_bus[0*8+:8]),
  .n_rst_ext(n_rst_ext)
);



// addresses 0x01-0x04
if_spi_multi #(
  .N_SLAVES(4),
  .CPOL(0),
  .CPHA(1),
  .BYTES_PER_FRAME(2)
)
pot_power (
  .n_rst        (n_rst),
  .sys_clk      (sys_clk),
  .sclk_common  (sclk_common),
  .sclk         (sclk_power),
  .mosi         (din_power),
  .miso         (),
  .n_cs_bus     ({sync_limit_input, sync_avdd, sync_dvdd, sync_vdd}),  
  .m_din        (master_data),
  .m_wrreq_bus  (valid_bus[4:1]),
  .s_dout   (slave_data_bus[1*8+:8]),
  .len      (len_bus[1*8+:8]),
  .have_msg_bus (have_msg_bus[4:1]),
  .s_rdreq_bus  (rdreq_bus[4:1])
);



// addresses 0x05-0x08
if_spi_multi #(
  .N_SLAVES(4),
  .CPOL(0),
  .CPHA(1),
  .BYTES_PER_FRAME(2)
)
pot_cmp_oa (
  .n_rst        (n_rst),
  .sys_clk      (sys_clk),
  .sclk_common  (sclk_common),
  .sclk         (sclk_cmp_oa),
  .mosi         (din_cmp_oa),
  .miso         (),
  .n_cs_bus     ({sync_oa_1, sync_oa_0, sync_cmp_b, sync_cmp_a}),  
  .m_din        (master_data),
  .m_wrreq_bus  (valid_bus[8:5]),
  .s_dout   (slave_data_bus[2*8+:8]),
  .len      (len_bus[2*8+:8]),
  .have_msg_bus (have_msg_bus[8:5]),
  .s_rdreq_bus  (rdreq_bus[8:5])
);



// address 0x09
if_spi #(
  .CPOL(1),
  .CPHA(1),
  .BYTES_PER_FRAME(2)
)
adc_power (
  .n_rst       (n_rst),
  .sys_clk     (sys_clk),
  .sclk_common (sclk_common),
  .n_cs        (pwr_adc_cs),
  .sclk        (pwr_adc_sclk),
  .mosi        (pwr_adc_din),
  .miso        (pwr_adc_dout),
  .in_data     (master_data),
  .in_ena      (valid_bus[9]),
  .enc_rdreq   (rdreq_bus[9]),
  .out_data    (slave_data_bus[3*8+:8]),
  .have_msg    (have_msg_bus[9]),
  .len         (len_bus[3*8+:8])
);



// addresses 0x0A-0x0C
if_spi_multi #(
  .N_SLAVES(3),
  .CPOL(1),
  .CPHA(1),
  .BYTES_PER_FRAME(2)
)
adcs (
  .n_rst       (n_rst),
  .sys_clk     (sys_clk),
  .sclk_common (sclk_common),
  .sclk        (adc_sclk),
  .mosi        (adc_din),
  .miso        (adc_dout),
  .n_cs_bus    ({adc_cs_3, adc_cs_2, adc_cs_1}),  
  .m_din       (master_data),
  .m_wrreq_bus (valid_bus[12:10]),
  .s_dout  (slave_data_bus[4*8+:8]),
  .len     (len_bus[4*8+:8]),
  .have_msg_bus(have_msg_bus[12:10]),
  .s_rdreq_bus (rdreq_bus[12:10])
);



// addresses 0x0D-0x27
regs regs (
  .n_rst (n_rst),
  .clk (sys_clk),
  .master_data (master_data),
  .valid_bus (valid_bus[39:13]),
  .rdreq_bus (rdreq_bus[39:13]),
  .have_msg_bus (have_msg_bus[40:13]),
  .slave_data (slave_data_bus[5*8+:8]),
  .len (len_bus[5*8+:8]),
  
  .sbis_functcontrol_stop (sbis_functcontrol_stop),
  .gpio_o_144_159 (gpio_o_144_159),
  .gpio_o_128_143 (gpio_o_128_143),
  .gpio_o_112_127 (gpio_o_112_127),
  .gpio_o_96_111 (gpio_o_96_111),
  .gpio_o_80_95 (gpio_o_80_95),
  .gpio_o_64_79 (gpio_o_64_79),
  .gpio_o_48_63 (gpio_o_48_63),
  .gpio_o_32_47 (gpio_o_32_47),
  .gpio_o_16_31 (gpio_o_16_31),
  .gpio_o_0_15 (gpio_o_0_15),
  
  .gpio_io_32_49 (gpio_io_32_49),
  .gpio_io_16_31 (gpio_io_16_31),
  .gpio_io_0_15 (gpio_io_0_15),
  
  .rst_power (rst_power),
  .off_vdd (off_vdd),
  .off_dvdd (off_dvdd),
  .off_avdd (off_avdd),
  .off_limit_input (off_limit_input),
  .rst_cmp_oa (rst_cmp_oa),
  .funct_en_1 (funct_en_1),
  .addr (addr),
  .nce_fl1 (nce_fl1),
  .nce_fl2 (nce_fl2),
  .en_gpio_fl1 (en_gpio_fl1),
  .cpu_cfg (cpu_cfg),
  .clk_gen_control (clk_gen_control),
  .csa (csa),
  .funct_en (funct_en),
  .a_gpio (a_gpio),
  .load_pdr_0 (load_pdr_0),
  .load_pdr_5v5_1 (load_pdr_5v5_1),
  .load_pdr_5v0_1 (load_pdr_5v0_1),
  .load_pdr_4v5_1 (load_pdr_4v5_1),
  .rstn (rst_n),
  
  .i2c_speed (i2c_speed),
  .clk_enable (clk_enable)
);



// addresses 0x28-0x2B
if_i2c_master if_i2c_master (
  .n_rst (n_rst),
  .clk (sys_clk),
  
  .i2c_speed (i2c_speed),
  .scl_bus (s_scl),
  .sda_bus (s_sda),
  .sreset_bus (s_sreset),
  .sstat_bus (s_sstat),
  
  .m_din (master_data),
  .m_wrreq_bus (valid_bus[43:40]),
  .have_msg_bus (have_msg_bus[43:40]),
  .s_rdreq_bus (rdreq_bus[43:40]),
  .s_dout (slave_data_bus[6*8+:8]),
  .len (len_bus[6*8+:8])
);



// addresses 0x2C-0x37
if_i2c_slave if_i2c_slave (
  .n_rst (n_rst),
  .clk (sys_clk),
  .my_dev_address (addr),
  
  .scl_bus (m_scl),
  .sda_bus (m_sda),
  .sreset_bus (m_sreset),
  .sstat_bus (m_sstat),

  .have_msg_bus (have_msg_bus[55:44]),
  .s_rdreq_bus (rdreq_bus[55:44]),
  .s_dout (slave_data_bus[7*8+:8]),
  .len (len_bus[7*8+:8]),
  
  .master_data (master_data),
  .master_ena_bus (valid_bus[55:44])
);

//if_i2c_fake_master if_i2c_fake_master (
//  .n_rst (n_rst),
//  .clk (sys_clk),
//  
//  .i2c_speed (i2c_speed),
//  .scl_bus (m_scl),
//  .sda_bus (m_sda),
//  .sreset_bus (m_sreset),
//  .sstat_bus (m_sstat),
//  
//  .m_din (master_data),
//  .m_wrreq_bus (valid_bus[55:44]),
//  .have_msg_bus (have_msg_bus[55:44]),
//  .s_rdreq_bus (rdreq_bus[55:44]),
//  .s_dout (slave_data_bus[7*8+:8]),
//  .len (len_bus[7*8+:8])
//);

// clock to debug I2C
/*
reg [3:0] stp_counter;

always @ (posedge sclk_common or negedge n_rst)
  if (!n_rst)
    begin
    stp_clk <= 0;
    stp_counter <= 0;
    end
  else
    begin
    if (stp_counter < 4'd7)
      stp_counter <= stp_counter + 1'b1;
    else
      begin
      stp_counter <= 0;
      stp_clk <= !stp_clk;
      end
    end
*/


// debug outputs
//assign my_tx_data = tx_data;
//assign my_tx_valid = tx_valid;

endmodule