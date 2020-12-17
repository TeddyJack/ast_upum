module i2c_slave_teddy (
  input clk,
  input n_rst,
  input [6:0] my_dev_address,
  input sda_i,
  output reg sda_o,
  output sda_oen,
  input scl,
  output reg [7:0] out_data,
  output out_ena,
  output ready
  // debug ports
  //output [3:0] my_state,
  //output my_sda_o,
  //output my_sda_oen,
  //output my_read
);
//assign my_state = state;
//assign my_sda_o = sda_o;
//assign my_sda_oen = sda_oen;
//assign my_read = read;



assign sda_oen = (state == SET_ACK) | (state == SET_DATA);
assign out_ena = (state == SET_ACK) & rising_scl;
assign ready = !transfer_in_progress;





reg delayed_scl;
reg rising_scl;
reg falling_scl;
reg delayed_sda;
reg rising_sda;
reg falling_sda;

always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    begin
    delayed_scl <= 1;
    delayed_sda <= 1;
    rising_scl <= 0;
    rising_sda <= 0;
    falling_scl <= 0;
    falling_sda <= 0;
    end
  else
    begin
    delayed_scl <= scl;
    rising_scl <= scl & !delayed_scl;
    falling_scl <= !scl & delayed_scl;
    delayed_sda <= sda_i;
    rising_sda <= sda_i & !delayed_sda;
    falling_sda <= !sda_i & delayed_sda;
    end

reg [3:0] state;
localparam IDLE = 0;
localparam GET_DEV_ADDR = 1;
localparam SET_ACK = 2;
localparam GET_DATA = 3;
localparam SET_DATA = 4;
localparam GET_ACK = 5;

reg [2:0] cnt;
reg transfer_in_progress;
reg sync_rst;
reg read;

always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    begin
    state <= IDLE;
    cnt <= 0;
    sda_o <= 1;
    out_data <= 0;
    transfer_in_progress <= 0;
    sync_rst <= 0;
    read <= 0;
    end
  else
    begin
    if (scl & falling_sda)    // i2c start condition
      transfer_in_progress <= 1;
    else if (scl & rising_sda)  // i2c stop condition
      transfer_in_progress <= 0;
    
    sync_rst <= (scl & falling_sda) | (scl & rising_sda);
    
    
    if (sync_rst)
      begin
      cnt <= 0;
      sda_o <= 1;
      state <= IDLE;
      read <= 0;
      end
    else if (transfer_in_progress & falling_scl)
      case (state)
      IDLE:
        state <= GET_DEV_ADDR;
      GET_DEV_ADDR:
        begin
        out_data[0] <= sda_i;
        out_data[7:1] <= out_data[6:0];
        cnt <= cnt + 1'b1;
        if (cnt == 3'd7)
          begin
          if (out_data[6:0] == my_dev_address)
            begin
            state <= SET_ACK;
            sda_o <= 0;
            if (sda_i)
              read <= 1;
            end
          //else stay in this state to detect right dev addr
          end
        end
      SET_ACK:
        begin
        sda_o <= 1;
        if (read)
          state <= SET_DATA;
        else
          state <= GET_DATA;
        end
      GET_DATA:
        begin
        out_data[0] <= sda_i;
        out_data[7:1] <= out_data[6:0];
        cnt <= cnt + 1'b1;
        if (cnt == 3'd7)
          begin
          state <= SET_ACK;
          sda_o <= 0;
          end
        end
      SET_DATA:
        begin
        sda_o <= out_data[7];
        out_data[7:1] <= out_data[6:0];
        out_data[0] <= out_data[7];
        cnt <= cnt + 1'b1;
        if (cnt == 3'd7)
          state <= GET_ACK;
        end
      GET_ACK:
        begin
        if (sda_i)
          state <= IDLE;
        else
         state <= SET_DATA;
        end
      endcase
    end




endmodule