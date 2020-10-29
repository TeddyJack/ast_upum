`define PREFIX      8'hEE
`define TIMEOUT_MSG 1000            // in milliseconds
`define N_SRC       (1+12+27+4+12)  // keep alive + N_SPI + N_regs + N_I2C_master + N_I2C_slaves
`define N_INPUTS    8               // number of combined sources/destinations
`define SYS_CLK     100             // in MHz
`define BAUDRATE    230400