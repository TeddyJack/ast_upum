module muxer_unitary #(
  parameter WIDTH = 8,
  parameter NUM = 4
)(
  input [NUM*WIDTH-1:0] data_in_bus,
  input [NUM-1:0] ena_in_bus,
  output [WIDTH-1:0] data_out
);

// vars
genvar i;
wire [WIDTH-1:0] data_packed [NUM-1:0];
wire [WIDTH-1:0] data_anded [NUM-1:0];  // or strobed
wire [WIDTH-1:0] data_ored [NUM-1:0];

// assigns
assign data_ored[0] = data_anded[0];
assign data_out = data_ored[NUM-1];


// main logic
generate for (i = 0; i < NUM; i = i + 1)
  begin: packing_anding
  assign data_packed[i] = data_in_bus[i*WIDTH+:WIDTH];
  assign data_anded[i] = data_packed[i] & {WIDTH{ena_in_bus[i]}};
  end
endgenerate



generate for (i = 1; i < NUM; i = i + 1)
  begin: oring
    assign data_ored[i] = data_ored[i-1] | data_anded[i];
  end
endgenerate



endmodule