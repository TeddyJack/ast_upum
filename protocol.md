# Сообщение верхнего уровня

  | Structural part of message       | Bytes |
  |----------------------------------|-------|
  | Prefix = 0xEE                    | 1     |
  | Address of destination / source  | 1     |
  | Length of payload                | 1     |
  | Payload                          | 0-255 | 
  | Checksum                         | 1     |

Checksum - сумма по модулю 256 всех байт в сообщении кроме Prefix’а.
Для всех адресатов c интерфейсом IO длина поля данных всегда = 1 байт.


# Sources and destinations

  | Address | Type          | D                | IF   | w/r  | Descr                  |
  |---------|---------------|------------------|------|------|------------------------|
  | 0x00    | service       |                  | IO   |      | keep alive, reset      |
  | 0x01    | Pot (5293)    | Power: 17        | SPI  | w    | vdd                    |
  | 0x02    | Pot (5293)    | Power: 1         | SPI  | w    | dvdd                   |
  | 0x03    | Pot (5293)    | Power: 2         | SPI  | w    | avdd                   |
  | 0x04    | Pot (5293)    | Power: 18        | SPI  | w    | limit_input            |
  | 0x05    | Pot (5293)    | 79               | SPI  | w    | cmp_a                  |
  | 0x06    | Pot (5293)    | 80               | SPI  | w    | cmp_b                  |
  | 0x07    | Pot (5293)    | 81               | SPI  | w    | oa_0                   |
  | 0x08    | Pot (5293)    | 82               | SPI  | w    | oa_1                   |
  | 0x09    | ADC (7328)    | 1                | SPI  | w/r  | pwr                    |
  | 0x0A    | ADC (7328)    | 29               | SPI  | w/r  | gpio_o_0-127           |
  | 0x0B    | ADC (7328)    | 30               | SPI  | w/r  | gpio_o_128-159         |
  | 0x0C    | ADC (7328)    | 39               | SPI  | w/r  | gpio_io_0-49           |
  | 0x0D    | Logic "or"    | 75               | IO   | r    | sbis_functcontrol_stop |
  | 0x0E    | SBIS_UPUM     |                  | IO   | r    | cmp_o                  |
  | 0x0F    | Mux           | 6-13             | IO   | r    | gpio_o_0-127           |
  | 0x10    | Mux           | 14,15            | IO   | r    | gpio_o_128-159         |
  | 0x11    | Mux/demux     | 31-33            | IO   | w    | gpio_io_0-49           |
  | 0x12    | Pot (5293)    | Power: 1,2,17,18 | IO   | w    | rst_power              |
  | 0x13    | Pot (5293)    | Power: 17        | IO   | w    | off_vdd                |
  | 0x14    | Pot (5293)    | Power: 1         | IO   | w    | off_dvdd               |
  | 0x15    | Pot (5293)    | Power: 2         | IO   | w    | off_avdd               |
  | 0x16    | Pot (5293)    | Power: 18        | IO   | w    | off_limit_input        |
  | 0x17    | Pot (5293)    | 79-82            | IO   | w    | rst_cmp_oa             |
  | 0x18    | I2C repeater  | 50-65            | IO   | w    | funct_en_1             |
  | 0x19    | SBIS UPUM     |                  | IO   | w    | addr                   |
  | 0x1A    | Flash mem     | 45               | IO   | w    | nce_fl1                |
  | 0x1B    | Flash mem     | 46               | IO   | w    | nce_fl2                |
  | 0x1C    | Level transl  | 40-44            | IO   | w    | en_gpio_fl1            |
  | 0x1D    | SBIS UPUM     |                  | IO   | w    | cpu_cfg                |
  | 0x1E    | SBIS UPUM     |                  | IO   | w    | flash_gpio_dir         |
  |         |               |                  |      |      | (ex. clk_gen_control)  |
  | 0x1F    | SBIS UPUM     |                  | IO   | w    | gpio_io_ena (ex. csa)  |
  | 0x20    | Level transl  | 26-28,37,38,     | IO   | w    | funct_en               |
  |         |               | 47-49,66-69      |      |      |                        |
  | 0x21    | Mux/demux     | 6-15,31-33       | IO   | w    | a_gpio                 |
  | 0x22    | Switch        | 16-25,34-36      | IO   | w    | load_pdr_0             |
  | 0x23    | Switch        | 16-25,34-36      | IO   | w    | load_pdr_5v5_1         |
  | 0x24    | Switch        | 16-25,34-36      | IO   | w    | load_pdr_5v0_1         |
  | 0x25    | Switch        | 16-25,34-36      | IO   | w    | load_pdr_4v5_1         |
  | 0x26    | SBIS_UPUM     |                  | IO   | w    | rstn                   |
  | 0x27    | special       |                  | IO   | w    | i2c_speed              |
  | 0x28    | SBIS UPUM     |                  | I2C  | w/r  | I2C slave 0            |
  | 0x29    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 1            |
  | 0x2A    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 2            |
  | 0x2B    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 3            |
  | 0x2C    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 4            |
  | 0x2D    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 5            |
  | 0x2E    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 6            |
  | 0x2F    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 7            |
  | 0x30    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 8            |
  | 0x31    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 9            |
  | 0x32    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 10           |
  | 0x33    | SBIS_UPUM     |                  | I2C  | w/r  | I2C slave 11           |


# Address 0x00

  | Команда    | Data | Ответ |
  |------------|------|-------|
  | Keep alive | 0xAE | 0xEA  |
  | Reset FPGA | 0xF0 |   -   |


# Адресаты 0x0D... 0x27
Они являются регистрами, либо проводами напрямую от СБИС УПУМ.
Все кроме ниже указанных содержат значение сигнала в младшем бите [0] поля данных.
Для чтения данных с адресатов типа Read Only, требуется отправить любое значение по его адресу, оно не будет записано.
Для записи данных в адресат типа Write Only - тут всё понятно. Чтение данных из адресатов Write Only не предусмотрено.
Адресаты, содержащие сигнал reset, например, rst_power или rst_cmp_oa, НЕ делают одиночный reset, а хранят записанное значение.

# Address 0x0E

  | № бита | значение   |
  |--------|------------|
  | [7:4]  |    -       |
  | [3:0]  | cmp_o[3:0] |


# Address 0x0F

  | № бита | значение       |
  |--------|----------------|
  | [7]    | gpio_o_112_127 |
  | [6]    | gpio_o_96_111  |
  | [5]    | gpio_o_80_95   |
  | [4]    | gpio_o_64_79   |
  | [3]    | gpio_o_48_63   |
  | [2]    | gpio_o_32_47   |
  | [1]    | gpio_o_16_31   |
  | [0]    | gpio_o_0_15    |


# Address 0x10

  | № бита | значение       |
  |--------|----------------|
  | [7:2]  |       -        |
  | [1]    | gpio_o_144_159 |
  | [0]    | gpio_o_128_143 |


# Address 0x11

  | № бита | значение       |
  |--------|----------------|
  | [7:3]  |       -        |
  | [2]    | gpio_io_32_49  |
  | [1]    | gpio_io_16_31  |
  | [0]    | gpio_io_0_15   |


# Address 0x19

  | № бита | значение |
  |--------|----------|
  | [7]    |    -     |
  | [6:0]  | addr     |


# Address 0x1E

  | № бита | значение |
  |--------|----------|
  | [7:2]  |    -     |
  | [1:0]  | cpu_cfg  |


# Address 0x21

  | № бита | значение |
  |--------|----------|
  | [7:4]  |    -     |
  | [3:0]  | a_gpio   |


# Address 0x27

  | № бита | значение  |
  |--------|-----------|
  | [7:1]  |     -     |
  | [0]    | i2c_speed |

  i2c_speed:
  
  | код | расшифровка |
  |-----|-------------|
  | 0   | 100 kbit/s  |
  | 1   | 400 kbit/s  |


# Address 0x28... 0x33

  Формат сообщения при записи:
  
  | Structural part of message            | Bytes             |
  |---------------------------------------|-------------------|
  | [7:1] = I2C device address, [0] = "0" | 1                 |
  | Length of address                     | 1                 |
  | Length of data                        | 1                 |
  | Address                               | Length of address | 
  | Data                                  | Length of data    |

  Формат сообщения при чтении:
  
  | Structural part of message            | Bytes             |
  |---------------------------------------|-------------------|
  | [7:1] = I2C device address, [0] = "1" | 1                 |
  | Length of address                     | 1                 |
  | Length of data                        | 1                 |
  | Address                               | Length of address |
