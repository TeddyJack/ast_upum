`define PREFIX      8'hEE
`define TIMEOUT_MSG 1000    // in milliseconds
`define N_SRC       (1+12+27+12) // keep alive + N_SPI + N_regs + N_I2C
`define N_INPUTS    7
`define SYS_CLK     100      // in MHz
`define BAUDRATE    230400