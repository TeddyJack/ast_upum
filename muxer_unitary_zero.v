module muxer_unitary_zero #(
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
wire [WIDTH-1:0] data_nored [NUM-1:0];  // or strobed
wire [WIDTH-1:0] data_anded [NUM-1:0];

// assigns
assign data_anded[0] = data_nored[0];
assign data_out = data_anded[NUM-1];


// main logic
generate for (i = 0; i < NUM; i = i + 1)
  begin: packing_noring
  assign data_packed[i] = data_in_bus[i*WIDTH+:WIDTH];
  assign data_nored[i] = data_packed[i] | ~{WIDTH{ena_in_bus[i]}};
  end
endgenerate



generate for (i = 1; i < NUM; i = i + 1)
  begin: anding
    assign data_anded[i] = data_anded[i-1] & data_nored[i];
  end
endgenerate



endmodule