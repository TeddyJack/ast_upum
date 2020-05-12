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

  | Address | Type          | Name   | ID         | IF   | w/r  | Descr          |
  |---------|---------------|--------|------------|------|------|----------------|
  | 0x00    | Potentiometer | AD5293 | Power: D17 | SPI  | w    | vdd            |
  | 0x01    | Potentiometer | AD5293 | Power: D1  |      |      | dvdd           |
  | 0x02    | Potentiometer | AD5293 | Power: D2  |      |      | avdd           |
  | 0x03    | Potentiometer | AD5293 | Power: D18 |      |      | limit input    |
  | 0x04    | Potentiometer | AD5293 | D79        |      |      | cmp a          |
  | 0x05    | Potentiometer | AD5293 | D80        |      |      | cmp b          |
  | 0x06    | Potentiometer | AD5293 | D81        |      |      | oa 0           |
  | 0x07    | Potentiometer | AD5293 | D82        |      |      | oa 1           |
  | 0x08    | ADC           | AD7328 | D1         | SPI  | w/r  | pwr            |
  | 0x09    | ADC           | AD7328 | D29        |      |      | gpio o 0-127   |
  | 0x0A    | ADC           | AD7328 | D30        |      |      | gpio o 128-159 |
  | 0x0B    | ADC           | AD7328 | D39        |      |      | gpio io 0-49   |
  | 0x0C    |               |        |            |      |      |                |
  |         |               |        |            |      |      |                |
  |         |               |        |            |      |      |                |
  |         |               |        |            |      |      |                |