create_clock -period 180MHz [get_ports clk_100]


derive_pll_clocks -create_base_clocks

derive_clock_uncertainty

