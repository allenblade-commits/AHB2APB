module ahb_slave_interface(
    input hclk,           // Clock input
    input hresetn,        // Active low reset
    input hwrite,         // Write signal
    input hready_in,      // Ready input signal
    input [1:0] htrans,   // Transaction type input
    input [31:0] hwdata,  // Write data
    input [31:0] haddr,   // Address input
    input [31:0] pr_data, // Processor data input
    output reg hwrite_reg,  // Pipelined write signal
    output reg hwrite_reg1, // 2nd stage pipelined write signal
    output reg valid,       // Valid signal for address checking
    output reg [31:0] hwdata1, hwdata2, // Pipelined write data
    output reg [31:0] haddr1, haddr2,   // Pipelined address
    output [31:0] hr_data,              // Output data
    output reg [2:0] temp_sel           // Selection signal based on address range
);

// Pipeline logic for haddr signals
always @(posedge hclk) begin
    if (!hresetn) begin
        haddr1 <= 0;   // Reset haddr1
        haddr2 <= 0;   // Reset haddr2
    end else begin
        haddr1 <= haddr;    // Stage 1: Latch current haddr to haddr1
        haddr2 <= haddr1;   // Stage 2: Latch haddr1 to haddr2
    end
end

// Pipeline logic for hwdata and hwrite signals
always @(posedge hclk) begin
    if (!hresetn) begin
        hwdata1 <= 0;  // Reset hwdata1
        hwdata2 <= 0;  // Reset hwdata2
    end else begin
        hwdata1 <= hwdata;   // Stage 1: Latch current hwdata to hwdata1
        hwdata2 <= hwdata1;  // Stage 2: Latch hwdata1 to hwdata2
    end
end

// Pipelining logic for hwrite signals (hwrite_reg, hwrite_reg1)
always @(posedge hclk) begin
    if (!hresetn) begin
        hwrite_reg  <= 0;   // Reset hwrite_reg
        hwrite_reg1 <= 0;   // Reset hwrite_reg1
    end else begin
        hwrite_reg  <= hwrite;       // Stage 1: Latch current hwrite to hwrite_reg
        hwrite_reg1 <= hwrite_reg;   // Stage 2: Latch hwrite_reg to hwrite_reg1
    end
end

// Valid signal logic
// Checks: hready_in = 1, htrans = 2'b10 or 2'b11, and haddr within a specific range
always @(*) begin
    valid = 1'b0; // Default invalid
    if (hready_in == 1 && (htrans == 2'b10 || htrans == 2'b11) && 
       (haddr >= 32'h0000_0000 && haddr <= 32'h8c00_0000)) begin
        valid = 1'b1; // Set valid if conditions are met
    end
end

// Temp selection logic based on address ranges
always @(*) begin
    if (haddr >= 32'h8000_0000 && haddr < 32'h8400_0000) begin
        temp_sel = 3'b001;  // Select 1 if address is in this range
    end else if (haddr >= 32'h8400_0000 && haddr < 32'h8c00_0000) begin
        temp_sel = 3'b010;  // Select 2 if address is in this range
    end else begin
        temp_sel = 3'b000;  // Default selection
    end
end

// Directly assign pr_data to hr_data
assign hr_data = pr_data;

endmodule
