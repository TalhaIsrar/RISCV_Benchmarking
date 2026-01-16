module mem_stage(
    input clk,
    input rst,
    input [31:0] result,
    input [31:0] op2_data,
    input mem_write,
    input [1:0] store_type,
    input [2:0] load_type,
    output reg [31:0] read_data,
    output wire [31:0] calculated_result
);
 
    assign calculated_result = result;

    wire [31:0] timer_val, mem_read_data;
    wire uartWen, dmemWenFinal;
    wire [7:0] uartData;

    assign uartData = op2_data[7:0];
    assign uartWen = mem_write & (result == 32'hFFFF_FFFC);

    assign dmemWenFinal = mem_write && (!uartWen);


    reg [31:0] result_delay;
    // Next PC Register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result_delay <= 32'h00000000; // Reset PC to 0
        end else begin
            result_delay <= result;
        end
    end

    wire read_timer = (result_delay == 32'hFFFF_FF00);
    assign read_data = read_timer ? timer_val : mem_read_data;

    dmem data(
         .wData(op2_data),
         .rData(mem_read_data),
         .clk(clk),
         .wEn(dmemWenFinal),
         .addr(result - 32'h10000000),
         .size(load_type)
       );

    uart uartsim(
            .clk(clk),
            .rst(rst),
            .data(uartData),
            .wEn(uartWen)
          );

    timer Simtime(
          .clk(clk),
          .rst(rst),
          .cycle_count(timer_val)
    );

endmodule