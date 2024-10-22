module bridge_top(
    input hclk,              // Clock input
    input hresetn,           // Active low reset
    input hwrite,            // Write signal from AHB
    input hready_in,         // Ready input from AHB
    input [1:0] htrans,      // Transaction type signal from AHB
    input [31:0] hwdata,     // Write data from AHB
    input [31:0] haddr,      // Address from AHB
    input [31:0] pr_data,    // Processor data

    output penable,          // Enable signal for APB
    output pwrite,           // Write signal for APB
    output hr_readyout,      // Ready output for AHB
    output [2:0] psel,       // Peripheral select signal for APB
    output [1:0] hres,       // AHB response (can be expanded if needed)
    output [31:0] paddr,     // Address for APB
    output [31:0] pwdata,    // Write data for APB
    output [31:0] hr_data    // Read data to AHB
);

// Internal signals for pipelined data and addresses
wire [31:0] hwdata1, hwdata2; // Pipelined write data
wire [31:0] haddr1, haddr2;   // Pipelined addresses
wire [2:0] temp_sel;          // Selection signal based on AHB address range
wire hwrite_reg, hwrite_reg1; // Latched write signals for pipelining
wire valid;                   // Valid signal based on transaction type and address

// AHB slave interface instance
ahb_slave_interface A1 (
    .hclk(hclk),
    .hresetn(hresetn),
    .hwrite(hwrite),
    .hready_in(hready_in),
    .htrans(htrans),
    .hwdata(hwdata),
    .haddr(haddr),
    .pr_data(pr_data),
    .hwrite_reg(hwrite_reg),
    .hwrite_reg1(hwrite_reg1),
    .valid(valid),
    .hwdata1(hwdata1),
    .hwdata2(hwdata2),
    .haddr1(haddr1),
    .haddr2(haddr2),
    .hr_data(hr_data),
    .temp_sel(temp_sel)
);

// APB controller instance
apb_controller A2 (
    .hclk(hclk),
    .hresetn(hresetn),
    .hwrite_reg(hwrite_reg),
    .hwrite_reg1(hwrite_reg1),
    .hwrite(hwrite),
    .valid(valid),
    .haddr(haddr),
    .hwdata(hwdata),
    .hwdata1(hwdata1),
    .hwdata2(hwdata2),
    .haddr1(haddr1),
    .haddr2(haddr2),
    .pr_data(pr_data),
    .temp_sel(temp_sel),
    .penable(penable),
    .pwrite(pwrite),
    .hr_readyout(hr_readyout),
    .psel(psel),
    .paddr(paddr),
    .pwdata(pwdata)
);

endmodule
