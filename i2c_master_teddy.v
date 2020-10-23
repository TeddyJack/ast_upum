module i2c_master_teddy (
  input [15:0] CLK_DIV,
  
  input       clk,
  input       n_rst,
  input       start,
  input       r_nw,     // 0 = write, 1 = read
  input [6:0] dev_addr,
  input [7:0] data_in,
  input [7:0] num_bytes_data,
  input [7:0] num_bytes_address,
  output      ready,
  
  input      sda_i,
  output reg sda_o,
  output     sda_oen,
  input      scl_i,
  output reg scl_o,
  output     scl_oen,
  
  output reg [7:0] out_data,
  output reg       out_ena,
  output reg       rd_req,
  
  // debug
  output [3:0] my_state,
  output [2:0] my_cnt_bit,
  output [7:0] my_cnt_byte,
  output       my_ack,
  output [15:0] my_cnt_clk,
  output       my_address_stage,
  output       my_rep_start
);

wire [15:0] CLK_DIV_MINUS_ONE = CLK_DIV - 1'b1;
wire [15:0] QUARTER = CLK_DIV >> 2;
wire [15:0] HALF = CLK_DIV >> 1;
wire [15:0] THREE_QUARTERS = HALF + QUARTER;

localparam IDLE         = 0;
localparam SET_START    = 1;
localparam SET_DEV_ADDR = 2;
localparam CHECK_ACK    = 3;
localparam SET_DATA     = 4;
localparam SET_STOP     = 5;
localparam GET_DATA     = 6;
localparam SET_ACK      = 7;

reg [3:0] state;
reg [2:0] cnt_bit;
reg [7:0] cnt_byte;
reg ack;    // 0 = acknowledged, 1 = not acknowledged
reg [15:0] cnt_clk;        // increase width LATER
reg address_stage;
wire [7:0] num_bytes = address_stage ? num_bytes_address : num_bytes_data;
wire rep_start = r_nw & (!address_stage);
wire [7:0] dev_addr_plus_r_nw = {dev_addr, rep_start};
wire last_byte_condition = (cnt_byte == num_bytes);

assign sda_oen = ((state == CHECK_ACK) | (state == GET_DATA)) ? 1'b0 : 1'b1;
assign scl_oen = 1'b1;
assign ready = (state == IDLE);


// state machine reg only
always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    state <= IDLE;
  else
    begin
    if (state == IDLE)
      begin
      if (start)
        state <= SET_START;
      end
    else  // all state except IDLE change at the end of cnt_clk
      if (cnt_clk == CLK_DIV_MINUS_ONE)
        case (state)
        SET_START:
          state <= SET_DEV_ADDR;
        SET_DEV_ADDR:
          if (cnt_bit == 0)
            state <= CHECK_ACK;
        CHECK_ACK:
          if (!ack)
            begin
            if (last_byte_condition)  // if last byte
              begin
              if (!r_nw)                //    if write, we go to stop
                state <= SET_STOP; 
              else                      //    if read, we go to repeating start
                state <= SET_START;
              end
            else                        // if not last byte
              begin
              if (rep_start)            //    if repeated start, go get first data
                state <= GET_DATA;
              else
                state <= SET_DATA;      //    if not repeated start, set next data
              end
            end
          else  // if nack
            state <= SET_STOP;
        SET_DATA:
          if (cnt_bit == 0)
            state <= CHECK_ACK;
        SET_STOP:
          state <= IDLE;
        GET_DATA:
          if (cnt_bit == 0)
            state <= SET_ACK;
        SET_ACK:
          if (last_byte_condition)
            state <= SET_STOP;
          else
            state <= GET_DATA;
        endcase
    end




always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    begin
    sda_o <= 1;
    cnt_bit <= 0;
    ack <= 1;
    cnt_byte <= 0;
    out_data <= 0;
    out_ena <= 0;
    address_stage <= 0;
    rd_req <= 0;
    end
  else
    begin
    if ((cnt_clk == 0) & ((state == SET_DEV_ADDR) | (state == SET_DATA) | (state == GET_DATA)))
      cnt_bit <= cnt_bit + 1'b1;
    
    
    //if (state == SET_STOP)
    //  cnt_byte <= 0;
    //else if ((state == SET_DATA) & (cnt_clk == 0) & (cnt_bit == 0))
    //  cnt_byte <= cnt_byte + 1'b1;
    if (state == SET_STOP)
      cnt_byte <= 0;
    else if ((cnt_clk == CLK_DIV_MINUS_ONE) & (cnt_bit == 0) & ((state == CHECK_ACK) | (state == SET_ACK)))
      begin
      if (cnt_byte == num_bytes)
        cnt_byte <= 0;
      else
        cnt_byte <= cnt_byte + 1'b1;
      end

    
    
    if (cnt_clk == HALF)  // in these states, regs change on half-period
      begin
      if ((state == SET_START) | (state == SET_STOP))
        sda_o <= ~sda_o;
      if (state == CHECK_ACK)
        ack <= sda_i;
      if (state == GET_DATA)
        begin
        out_data[7:1] <= out_data[6:0];
        out_data[0] <= sda_i;
        end
      end
    else if (cnt_clk == 0)  // in the remaining states, regs change at start of period
      case (state)
        SET_START:
          address_stage <= rep_start;
        SET_DEV_ADDR:
          sda_o <= dev_addr_plus_r_nw[3'd7 - cnt_bit];
        SET_DATA:
          sda_o <= data_in[3'd7 - cnt_bit];
        SET_ACK:
          begin
          if (last_byte_condition)
            sda_o <= 1;
          else
            sda_o <= 0;
          end
        CHECK_ACK:
          sda_o <= 1; // maybe????
        SET_STOP:
          begin
          sda_o <= 0; // maybe????
          address_stage <= 0;
          end
      endcase

    
    out_ena <= (cnt_clk == 0) & (state == SET_ACK);
    
    rd_req <= (cnt_clk == 0) & ((state == CHECK_ACK) & (!rep_start));
    
    end


// cnt_clk reg
always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    cnt_clk <= 0;
  else if (state == IDLE) // sync rst
    cnt_clk <= 0;
  else
    begin
    if (cnt_clk == CLK_DIV_MINUS_ONE)
      cnt_clk <= 0;
    else
      cnt_clk <= cnt_clk + 1'b1;
    end



// scl_o reg
always @ (posedge clk or negedge n_rst)
  if (!n_rst)
    scl_o <= 1;
  else
    begin
    if (cnt_clk == QUARTER)
      scl_o <= 1;
    else if ((cnt_clk == THREE_QUARTERS) & (state != SET_STOP))
      scl_o <= 0;
    
    // either expressions work. in case of no troubles, delete commented section
    //if (((cnt_clk == QUARTER) & (state != SET_START)) | ((cnt_clk == THREE_QUARTERS) & (state != SET_STOP)))
    //  scl_o <= ~scl_o;
    end





assign my_state = state;
assign my_cnt_bit = cnt_bit;
assign my_cnt_byte = cnt_byte;
assign my_ack = ack;
assign my_cnt_clk = cnt_clk;
assign my_address_stage = address_stage;
assign my_rep_start = rep_start;



endmodule