# Сообщение верхнего уровня

  | Structural part of message       | Bytes |
  |----------------------------------|-------|
  | Prefix = 0xDD                    | 1     |
  | Address of destination / source  | 1     |
  | Length of payload                | 1     |
  | Payload                          | 0-255 | 
  | Checksum                         | 1     |

Checksum - сумма по модулю 256 всех байт в сообщении кроме Prefix’а.


# Sources and destinations

  | Address | Type          | D                | IF   | w/r  | Descr                  |
  |---------|---------------|------------------|------|------|------------------------|
  | 0x00    | Pot (5293)    | Power: 17        | SPI  | w    | vdd                    |
  | 0x01    | Pot (5293)    | Power: 1         | SPI  | w    | dvdd                   |
  | 0x02    | Pot (5293)    | Power: 2         | SPI  | w    | avdd                   |
  | 0x03    | Pot (5293)    | Power: 18        | SPI  | w    | limit_input            |
  | 0x04    | Pot (5293)    | 79               | SPI  | w    | cmp_a                  |
  | 0x05    | Pot (5293)    | 80               | SPI  | w    | cmp_b                  |
  | 0x06    | Pot (5293)    | 81               | SPI  | w    | oa_0                   |
  | 0x07    | Pot (5293)    | 82               | SPI  | w    | oa_1                   |
  | 0x08    | ADC (7328)    | 1                | SPI  | w/r  | pwr                    |
  | 0x09    | ADC (7328)    | 29               | SPI  | w/r  | gpio_o_0-127           |
  | 0x0A    | ADC (7328)    | 30               | SPI  | w/r  | gpio_o_128-159         |
  | 0x0B    | ADC (7328)    | 39               | SPI  | w/r  | gpio_io_0-49           |
  | 0x0C    | Logic "or"    | 75               | IO   | r    | sbis_functcontrol_stop |
  | 0x0D    | SBIS_UPUM     |                  | IO   | r    | cmp_o                  |
  | 0x0E    | Mux           | 6-13             | IO   | r    | gpio_o_0-127           |
  | 0x0F    | Mux           | 14,15            | IO   | r    | gpio_o_128-159         |
  | 0x10    | Pot (5293)    | Power: 1,2,17,18 | IO   | w    | rst_power              |
  | 0x11    | Pot (5293)    | Power: 17        | IO   | w    | off_vdd                |
  | 0x12    | Pot (5293)    | Power: 1         | IO   | w    | off_dvdd               |
  | 0x13    | Pot (5293)    | Power: 2         | IO   | w    | off_avdd               |
  | 0x14    | Pot (5293)    | Power: 18        | IO   | w    | off_limit_input        |
  | 0x15    | Pot (5293)    | 79-82            | IO   | w    | rst_cmp_oa             |
  | 0x16    | I2C repeater  | 50-65            | IO   | w    | funct_en_1             |
  | 0x17    | SBIS UPUM     |                  | IO   | w    | addr                   |
  | 0x18    | Flash mem     | 45               | IO   | w    | nce_fl1                |
  | 0x19    | Flash mem     | 46               | IO   | w    | nce_fl2                |
  | 0x1A    | Level transl  | 40-44            | IO   | w    | en_gpio_fl1            |
  | 0x1B    | SBIS UPUM     |                  | IO   | w    | cpu_cfg                |
  | 0x1C    | SBIS UPUM     |                  | IO   | w    | clk_a                  |
  | 0x1D    | SBIS UPUM     |                  | IO   | w    | clk_gen_control        |
  | 0x1E    | SBIS UPUM     |                  | IO   | w    | csa                    |
  | 0x1F    | Level transl  | 26-28,37,38,     | IO   | w    | funct_en               |
  |         |               | 47-49,66-69      |      |      |                        |
  | 0x20    | Mux/demux     | 6-15,31-33       | IO   | w    | a_gpio                 |
  | 0x21    | Switch        | 16-25,34-36      | IO   | w    | load_pdr_0             |
  | 0x22    | Switch        | 16-25,34-36      | IO   | w    | load_pdr_5v5_1         |
  | 0x23    | Switch        | 16-25,34-36      | IO   | w    | load_pdr_5v0_1         |
  | 0x24    | Switch        | 16-25,34-36      | IO   | w    | load_pdr_4v5_1         |
  | 0x25    | Mux/demux     | 31-33            | IO   | w/r  | gpio_io_0-49           |
  | 0x26    | special       |                  | IO   | w    | gpio_z_state           |
            