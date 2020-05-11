# Сообщение верхнего уровня

  | Structural part of message       | Bytes |
  |----------------------------------|-------|
  | Prefix = 0xDD                    | 1     |
  | Address                          | 1     |
  | Length of payload                | 1     |
  | Payload                          | 0-255 | 
  | Checksum                         | 1     |




# Sources and destinations

  | Address | Type          | Name   | ID   | IF   | w/r  | Descr       |
  |---------|---------------|--------|------|------|------|-------------|
  | 0x00    | Potentiometer | AD5293 | D99  | SPI  | w/r  | vdd         |
  | 0x01    | Potentiometer | AD5293 |      |      |      | dvdd        |
  | 0x02    | Potentiometer | AD5293 |      |      |      | avdd        |
  | 0x03    | Potentiometer | AD5293 |      |      |      | limit_input |
  | 0x04    | Potentiometer | AD5293 |      |      |      | cmp a       |
  | 0x05    | Potentiometer | AD5293 |      |      |      | cmp b       |
  | 0x06    | Potentiometer | AD5293 |      |      |      | oa 0        |
  | 0x07    | Potentiometer | AD5293 |      |      |      | oa 1        |
  | 0x08    | ADC           | AD7328 |      |      |      |             |
  | 0x09    | ADC           | AD7328 |      |      |      |             |
  | 0x0A    | ADC           | AD7328 |      |      |      |             |
  | 0x0B    | ADC           | AD7328 |      |      |      |             |
  | 0x0C    | ADC           | AD7328 |      |      |      |             |
  | 0x0D    | ADC           | AD7328 |      |      |      |             |
  | 0x0E    | ADC           | AD7328 |      |      |      |             |
  | 0x0F    | ADC           | AD7328 |      |      |      |             |