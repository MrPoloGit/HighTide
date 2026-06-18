// Behavioral stubs mapping pa_spsram_* (ASIC abstract names) to the
// pa_f_spsram_* FPGA behavioral models included in the RTL.
// Selected for ICACHE_2K + DCACHE_2K — add more sizes if the cache
// configuration is changed via VERILOG_DEFINES.

// ICache data array (ICACHE_2K → 256×32)
module pa_spsram_256x32(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [7:0]  A;
  input         CEN, CLK, GWEN;
  input  [31:0] D, WEN;
  output [31:0] Q;
  pa_f_spsram_256x32 u(.A(A),.CEN(CEN),.CLK(CLK),.D(D),.GWEN(GWEN),.Q(Q),.WEN(WEN));
endmodule

// ICache tag array (ICACHE_2K → 32×47)
module pa_spsram_32x47(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [4:0]  A;
  input         CEN, CLK, GWEN;
  input  [46:0] D, WEN;
  output [46:0] Q;
  pa_f_spsram_32x47 u(.A(A),.CEN(CEN),.CLK(CLK),.D(D),.GWEN(GWEN),.Q(Q),.WEN(WEN));
endmodule

// DCache data array (DCACHE_2K → 128×32)
module pa_spsram_128x32(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [6:0]  A;
  input         CEN, CLK, GWEN;
  input  [31:0] D, WEN;
  output [31:0] Q;
  pa_f_spsram_128x32 u(.A(A),.CEN(CEN),.CLK(CLK),.D(D),.GWEN(GWEN),.Q(Q),.WEN(WEN));
endmodule

// DCache tag array (DCACHE_2K → 32×46)
module pa_spsram_32x46(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [4:0]  A;
  input         CEN, CLK, GWEN;
  input  [45:0] D, WEN;
  output [45:0] Q;
  pa_f_spsram_32x46 u(.A(A),.CEN(CEN),.CLK(CLK),.D(D),.GWEN(GWEN),.Q(Q),.WEN(WEN));
endmodule

// DCache dirty array (DCACHE_2K → 32×4)
module pa_spsram_32x4(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [4:0] A;
  input        CEN, CLK, GWEN;
  input  [3:0] D, WEN;
  output [3:0] Q;
  pa_f_spsram_32x4 u(.A(A),.CEN(CEN),.CLK(CLK),.D(D),.GWEN(GWEN),.Q(Q),.WEN(WEN));
endmodule

// BHT (hardcoded, cache-size-independent → 512×16)
module pa_spsram_512x16(A, CEN, CLK, D, GWEN, Q, WEN);
  input  [8:0]  A;
  input         CEN, CLK, GWEN;
  input  [15:0] D, WEN;
  output [15:0] Q;
  pa_f_spsram_512x16 u(.A(A),.CEN(CEN),.CLK(CLK),.D(D),.GWEN(GWEN),.Q(Q),.WEN(WEN));
endmodule
