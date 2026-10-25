// Pure combinational helpers for the independent Encoder0 parent v2.
// Include inside laya_m007_single_parent_v2; no state/payload declaration.
// Authority: source/m007_residual_encoder30_20261023.md section11.
// Compilation and integrated verification remain separate R006 attempts.
function automatic logic encoder0_f32_finite(input logic [31:0] value);
  return value[30:23] != 8'hff;
endfunction

// {any_nonfinite, smallest_nonfinite_lane}; lane0 has graph priority.
function automatic logic [5:0] encoder0_first_nonfinite(
  input logic [31:0][31:0] values
);
  logic [5:0] result;
  result = 6'b0;
  for (int lane = 31; lane >= 0; lane = lane - 1)
    if (!encoder0_f32_finite(values[lane])) result = {1'b1, 5'(lane)};
  return result;
endfunction

// Tensor metadata remains in the original two descriptor registers.
// This validates a replacement record before any overwrite handshake.
function automatic logic encoder0_ffn_descriptor_ok(
  input logic slot,
  input logic [31:0] tensor,
  input logic [3:0][63:0] bases,
  input logic [3:0][63:0] spans
);
  logic accepted;
  logic [64:0] endpoint;
  accepted = tensor == (slot ? 32'd88 : 32'd60);
  for (int channel = 0; channel < 4; channel = channel + 1) begin
    endpoint = {1'b0, bases[channel]} + {1'b0, spans[channel]};
    if (bases[channel][11:0] != 0 ||
        spans[channel] < (slot ? 64'd755712 : 64'd1511424) ||
        endpoint[64]) accepted = 1'b0;
  end
  return accepted;
endfunction

// All source inputs are ordered row-major; upper bits must be zero.
function automatic logic encoder0_input_coordinate_ok(
  input logic [12:0] accepted_count,
  input logic [7:0] row,
  input logic [7:0] group_index
);
  return accepted_count < 13'd4096 &&
         row == {1'b0, accepted_count[11:5]} &&
         group_index == {3'b0, accepted_count[4:0]};
endfunction

function automatic logic encoder0_projection_coordinate_ok(
  input logic [6:0] row,
  input logic [15:0] column
);
  return column < 16'd1024 && column[4:0] == 0;
endfunction

// The full public kind never passes through a two-bit legacy truncation.
function automatic logic [1:0] encoder0_island_kind(
  input logic [2:0] public_kind,
  input logic ffn_island
);
  if (public_kind == 3'd4) return ffn_island ? 2'd3 : 2'd0;
  case (public_kind)
    3'd0: return 2'd0;
    3'd1: return 2'd1;
    3'd2: return 2'd2;
    3'd3: return 2'd3;
    default: return 2'd0; // Invalid kinds are rejected before any island.
  endcase
endfunction
