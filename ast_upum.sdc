create_clock -period 100MHz [get_ports clk_100]
create_clock -period 25MHz [get_ports sclk_common]


derive_pll_clocks -create_base_clocks

derive_clock_uncertainty

