// Behavioral stubs for aq_spsram_* abstract SRAM names used in the C906 RTL.
// Interface matches the aq_f_spsram_* FPGA models: A (address), CEN (active-low
// chip enable), CLK, D (data in), GWEN (active-low global write enable),
// WEN (active-low per-bit write enable), Q (data out).
//
// These synthesize to flip-flop arrays via SYNTH_MEMORY_MAX_BITS.
// Replace with FakeRAM macros (via /generate-sram) for realistic P&R.

module aq_spsram_32x8(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [4:0] A;
  input           CEN, CLK, GWEN;
  input  [7:0] D, WEN;
  output reg [7:0] Q;
  reg [7:0] mem [0:31];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 8; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_32x60(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [4:0] A;
  input           CEN, CLK, GWEN;
  input  [59:0] D, WEN;
  output reg [59:0] Q;
  reg [59:0] mem [0:31];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 60; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_64x8(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [5:0] A;
  input           CEN, CLK, GWEN;
  input  [7:0] D, WEN;
  output reg [7:0] Q;
  reg [7:0] mem [0:63];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 8; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_64x58(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [5:0] A;
  input           CEN, CLK, GWEN;
  input  [57:0] D, WEN;
  output reg [57:0] Q;
  reg [57:0] mem [0:63];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 58; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_64x59(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [5:0] A;
  input           CEN, CLK, GWEN;
  input  [58:0] D, WEN;
  output reg [58:0] Q;
  reg [58:0] mem [0:63];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 59; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_64x88(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [5:0] A;
  input           CEN, CLK, GWEN;
  input  [87:0] D, WEN;
  output reg [87:0] Q;
  reg [87:0] mem [0:63];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 88; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_64x98(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [5:0] A;
  input           CEN, CLK, GWEN;
  input  [97:0] D, WEN;
  output reg [97:0] Q;
  reg [97:0] mem [0:63];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 98; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_128x8(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [6:0] A;
  input           CEN, CLK, GWEN;
  input  [7:0] D, WEN;
  output reg [7:0] Q;
  reg [7:0] mem [0:127];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 8; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_128x16(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [6:0] A;
  input           CEN, CLK, GWEN;
  input  [15:0] D, WEN;
  output reg [15:0] Q;
  reg [15:0] mem [0:127];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 16; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_128x59(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [6:0] A;
  input           CEN, CLK, GWEN;
  input  [58:0] D, WEN;
  output reg [58:0] Q;
  reg [58:0] mem [0:127];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 59; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_128x64(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [6:0] A;
  input           CEN, CLK, GWEN;
  input  [63:0] D, WEN;
  output reg [63:0] Q;
  reg [63:0] mem [0:127];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 64; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_128x88(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [6:0] A;
  input           CEN, CLK, GWEN;
  input  [87:0] D, WEN;
  output reg [87:0] Q;
  reg [87:0] mem [0:127];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 88; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_128x98(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [6:0] A;
  input           CEN, CLK, GWEN;
  input  [97:0] D, WEN;
  output reg [97:0] Q;
  reg [97:0] mem [0:127];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 98; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_256x8(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [7:0] A;
  input           CEN, CLK, GWEN;
  input  [7:0] D, WEN;
  output reg [7:0] Q;
  reg [7:0] mem [0:255];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 8; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_256x16(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [7:0] A;
  input           CEN, CLK, GWEN;
  input  [15:0] D, WEN;
  output reg [15:0] Q;
  reg [15:0] mem [0:255];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 16; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_256x59(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [7:0] A;
  input           CEN, CLK, GWEN;
  input  [58:0] D, WEN;
  output reg [58:0] Q;
  reg [58:0] mem [0:255];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 59; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_256x64(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [7:0] A;
  input           CEN, CLK, GWEN;
  input  [63:0] D, WEN;
  output reg [63:0] Q;
  reg [63:0] mem [0:255];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 64; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_256x88(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [7:0] A;
  input           CEN, CLK, GWEN;
  input  [87:0] D, WEN;
  output reg [87:0] Q;
  reg [87:0] mem [0:255];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 88; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_256x98(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [7:0] A;
  input           CEN, CLK, GWEN;
  input  [97:0] D, WEN;
  output reg [97:0] Q;
  reg [97:0] mem [0:255];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 98; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_512x16(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [8:0] A;
  input           CEN, CLK, GWEN;
  input  [15:0] D, WEN;
  output reg [15:0] Q;
  reg [15:0] mem [0:511];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 16; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_512x32(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [8:0] A;
  input           CEN, CLK, GWEN;
  input  [31:0] D, WEN;
  output reg [31:0] Q;
  reg [31:0] mem [0:511];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 32; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_512x59(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [8:0] A;
  input           CEN, CLK, GWEN;
  input  [58:0] D, WEN;
  output reg [58:0] Q;
  reg [58:0] mem [0:511];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 59; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_512x64(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [8:0] A;
  input           CEN, CLK, GWEN;
  input  [63:0] D, WEN;
  output reg [63:0] Q;
  reg [63:0] mem [0:511];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 64; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_1024x16(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [9:0] A;
  input           CEN, CLK, GWEN;
  input  [15:0] D, WEN;
  output reg [15:0] Q;
  reg [15:0] mem [0:1023];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 16; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_1024x32(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [9:0] A;
  input           CEN, CLK, GWEN;
  input  [31:0] D, WEN;
  output reg [31:0] Q;
  reg [31:0] mem [0:1023];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 32; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_1024x64(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [9:0] A;
  input           CEN, CLK, GWEN;
  input  [63:0] D, WEN;
  output reg [63:0] Q;
  reg [63:0] mem [0:1023];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 64; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_2048x32(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [10:0] A;
  input           CEN, CLK, GWEN;
  input  [31:0] D, WEN;
  output reg [31:0] Q;
  reg [31:0] mem [0:2047];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 32; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_2048x64(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [10:0] A;
  input           CEN, CLK, GWEN;
  input  [63:0] D, WEN;
  output reg [63:0] Q;
  reg [63:0] mem [0:2047];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 64; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

module aq_spsram_4096x32(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [11:0] A;
  input           CEN, CLK, GWEN;
  input  [31:0] D, WEN;
  output reg [31:0] Q;
  reg [31:0] mem [0:4095];
  integer i;
  always @(posedge CLK) begin
    if (!CEN) begin
      if (!GWEN)
        for (i = 0; i < 32; i = i + 1)
          if (!WEN[i]) mem[A][i] <= D[i];
      Q <= mem[A];
    end
  end
endmodule

