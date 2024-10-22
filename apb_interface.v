module apb_interface(
    input pwrite,                // Write enable signal
    input penable,               // Enable signal
    input [2:0] psel,            // Select signal for the peripheral
    input [31:0] paddr,          // Address bus
    input [31:0] pwdata,         // Write data bus
    output pwrite_out,           // Output write enable
    output penable_out,          // Output enable
    output [2:0] psel_out,       // Output select signal
    output [31:0] paddr_out,     // Output address
    output [31:0] pwdata_out,    // Output write data
    output reg [31:0] pr_data    // Read data from peripheral
);

assign pwrite_out = pwrite;       // Direct assignment of write enable output
assign penable_out = penable;     // Direct assignment of enable output
assign psel_out = psel;           // Direct assignment of select output
assign paddr_out = paddr;         // Direct assignment of address output
assign pwdata_out = pwdata;       // Direct assignment of write data output

// Read data logic
always @(*)
begin
    if (!pwrite && penable)       // If read operation (pwrite is low) and peripheral is enabled
        pr_data = {$random}%265;  // Assign random value between 0 to 264 to read data
    else
        pr_data = 32'h0;          // Default read data to 0
end

endmodule
