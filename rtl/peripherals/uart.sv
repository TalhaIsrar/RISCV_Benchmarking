module uart (
    input logic clk,
    input logic rst,
    input logic wEn,
    input logic [3:0] byte_en,
    input logic [31:0] data
  );

  always_ff@(posedge clk)
  begin
    if(!rst && wEn)
    begin
        if (byte_en[0]) $write("%c", data[7:0]);
        if (byte_en[1]) $write("%c", data[15:8]);
        if (byte_en[2]) $write("%c", data[23:16]);
        if (byte_en[3]) $write("%c", data[31:24]);
    end
  end
endmodule
