`timescale 1 ns / 1 ns  // timescale units / timescale precision
`define TUPS 1000000000 // timescale units per second. if 1 ns then TUPS = 10^9
`include "defines.v"


module tb();

reg clk_100;

reg rx;
wire tx;

wire rst_power; // resets potentiometer
wire sclk_power;
wire din_power;
wire sync_vdd;
wire sync_dvdd;
wire sync_avdd;
wire sync_limit_reg;
wire off_vdd;
wire off_dvdd;
wire off_avdd;
wire off_limit_reg;
// potentiometers (cmp = comparator; oa = op amp)
wire rst_cmp_oa;
wire sclk_cmp_oa;
wire din_cmp_oa;
wire sync_cmp_a;
wire sync_cmp_b;
wire sync_oa_0;
wire sync_oa_1;
// adc power
wire pwr_adc_sclk;
wire pwr_adc_din;
reg pwr_adc_dout;
wire pwr_adc_cs;
// adcs 1-3
wire adc_sclk;
wire adc_din;
reg adc_dout;
wire adc_cs_1;
wire adc_cs_2;
wire adc_cs_3;
wire [6:0] addr;
wire [7:0] my_tx_data;
wire my_tx_valid;
reg [3:0] cmp_o;
reg gpio_o_144_159;
reg gpio_o_128_143;
reg gpio_o_112_127;
reg gpio_o_96_111; 
reg gpio_o_80_95;
reg gpio_o_64_79;
reg gpio_o_48_63;
reg gpio_o_32_47;
reg gpio_o_16_31;
reg gpio_o_0_15;



ast_upum i1 (
  .adc_cs_1 (adc_cs_1),
  .adc_cs_2 (adc_cs_2),
  .adc_cs_3 (adc_cs_3),
  .adc_din (adc_din),
  .adc_dout (adc_dout),
  .adc_sclk (adc_sclk),
  .clk_100 (clk_100),
  .din_cmp_oa (din_cmp_oa),
  .din_power (din_power),
  .off_avdd (off_avdd),
  .off_dvdd (off_dvdd),
  .off_limit_input (off_limit_input),
  .off_vdd (off_vdd),
  .pwr_adc_cs (pwr_adc_cs),
  .pwr_adc_din (pwr_adc_din),
  .pwr_adc_dout (pwr_adc_dout),
  .pwr_adc_sclk (pwr_adc_sclk),
  .rst_cmp_oa (rst_cmp_oa),
  .rst_power (rst_power),
  .rx (rx),
  .sclk_cmp_oa (sclk_cmp_oa),
  .sclk_power (sclk_power),
  .sync_avdd (sync_avdd),
  .sync_cmp_a (sync_cmp_a),
  .sync_cmp_b (sync_cmp_b),
  .sync_dvdd (sync_dvdd),
  .sync_limit_input (sync_limit_input),
  .sync_oa_0 (sync_oa_0),
  .sync_oa_1 (sync_oa_1),
  .sync_vdd (sync_vdd),
  .tx (tx),
  .addr (addr),
  .my_tx_data (my_tx_data),
  .my_tx_valid (my_tx_valid),
  .cmp_o (cmp_o),
  //inout gpio_io_32_49,
  //inout gpio_io_16_31,
  //inout gpio_io_0_15,
  .gpio_o_144_159 (gpio_o_144_159),
  .gpio_o_128_143 (gpio_o_128_143),
  .gpio_o_112_127 (gpio_o_112_127),
  .gpio_o_96_111 (gpio_o_96_111),
  .gpio_o_80_95 (gpio_o_80_95),
  .gpio_o_64_79 (gpio_o_64_79),
  .gpio_o_48_63 (gpio_o_48_63),
  .gpio_o_32_47 (gpio_o_32_47),
  .gpio_o_16_31 (gpio_o_16_31),
  .gpio_o_0_15 (gpio_o_0_15)
);


// calculate timing constants
integer UART_D = `TUPS / `BAUDRATE;  // duration of each UART bit in ns
integer CLK_T = `TUPS / (`SYS_CLK * 1000000);
integer CLK_HALF = `TUPS / (`SYS_CLK * 1000000) / 2;


task automatic send_to_rx;
  input [7:0] value;
  integer i;
  begin: t1
    rx = 0; #UART_D;
    for(i=0; i<=7; i=i+1)
    begin: f1
      rx = value[i]; #UART_D;
    end
    rx = 1; #UART_D;
    #(3*UART_D);    // pause between bytes
  end
endtask

// generating clocks
always #CLK_HALF clk_100 = !clk_100;



//integer b;


initial
  begin
  $display("sys clk half period = %d\n", CLK_T);
  
  adc_dout = 0;
  clk_100 = 1;
  pwr_adc_dout = 0;
  rx = 1;
  cmp_o = 4'd6;
  gpio_o_144_159 = 1;
  gpio_o_128_143 = 0;
  gpio_o_112_127 = 1;
  gpio_o_96_111 = 0; 
  gpio_o_80_95 = 1;
  gpio_o_64_79 = 0;
  gpio_o_48_63 = 1;
  gpio_o_32_47 = 0;
  gpio_o_16_31 = 1;
  gpio_o_0_15 = 0;
  
  #(CLK_T/4)  // initial offset to 1/4 of period for easier clocking
 
  #(10*CLK_T)
  

  #(1000*CLK_T)
  /*
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h16);  // address of dest
  send_to_rx(8'h01);  // len
  send_to_rx(8'hAE);
  send_to_rx(8'hAE);  // crc
  */
  
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h09);  // address of dest
  send_to_rx(8'd02);  // len
  send_to_rx(8'h16); send_to_rx(8'h1D);
  send_to_rx(8'hCC);  // crc
  
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h0A);  // address of dest
  send_to_rx(8'h02);  // len
  send_to_rx(8'hA0); send_to_rx(8'h50);
  send_to_rx(8'hCC);  // crc
  
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h0B);  // address of dest
  send_to_rx(8'h02);  // len
  send_to_rx(8'hA0); send_to_rx(8'h50);
  send_to_rx(8'hCC);  // crc
  
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h18);  // address of dest
  send_to_rx(8'h01);  // len
  send_to_rx(8'h09);
  send_to_rx(8'hCC);  // crc
  
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h0F);  // address of dest
  send_to_rx(8'h01);  // len
  send_to_rx(8'h00);
  send_to_rx(8'hCC);  // crc
  
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h00);  // address of dest
  send_to_rx(8'h01);  // len
  send_to_rx(8'hAE);
  send_to_rx(8'hCC);  // crc
  
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h00);  // address of dest
  send_to_rx(8'h01);  // len
  send_to_rx(8'hF0);
  send_to_rx(8'hCC);  // crc
  /*
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h10);  // address of dest
  send_to_rx(8'd64);  // len
  for(b=1; b<=64; b=b+1)
    begin
    send_to_rx(b[7:0]);
    end

  send_to_rx(8'hCC);  // crc
  
  #5000
  
  send_to_rx(8'hEE);  // prefix
  send_to_rx(8'h15);  // address of dest
  send_to_rx(8'd01);  // len
  send_to_rx(8'h55);  // stop send
  send_to_rx(8'hCC);  // crc
  */
  
  #(150000*CLK_T)
  
  $display("Testbench end");
  $stop();
  end        

endmodule