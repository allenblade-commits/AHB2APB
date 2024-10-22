module top_tb();
    reg hclk, hresetn;                   // Clock and reset signals

    wire hr_readyout;                     // Ready output signal from AHB to APB bridge
    wire [31:0] hr_data, hwdata, haddr;   // Data and address signals
    wire [1:0] htrans;                    // Transaction type signal

    // Instantiation of the AHB master
    ahb_master AHB(
        .hclk(hclk), 
        .hresetn(hresetn), 
        .hr_readyout(hr_readyout), 
        .hr_data(hr_data), 
        .haddr(haddr), 
        .hwdata(hwdata),
        .hwrite(hwrite), 
        .hready_in(hready_in), 
        .htrans(htrans)
    );

    // Instantiation of the AHB to APB bridge
    bridge_top Bridge_top(
        .hclk(hclk), 
        .hresetn(hresetn), 
        .hwrite(hwrite), 
        .hready_in(hready_in), 
        .htrans(htrans), 
        .hwdata(hwdata), 
        .haddr(haddr), 
        .pr_data(pr_data),
        .penable(penable), 
        .pwrite(pwrite), 
        .hr_readyout(hr_readyout), 
        .psel(psel), 
        .hres(hres), 
        .paddr(paddr), 
        .pwdata(pwdata), 
        .hr_data(hr_data)
    );

    // Instantiation of the APB interface
    apb_interface APB(
        .pwrite(pwrite), 
        .penable(penable), 
        .psel(psel), 
        .paddr(paddr), 
        .pwdata(pwdata), 
        .pwrite_out(pwrite_out), 
        .penable_out(penable_out), 
        .psel_out(psel_out), 
        .paddr_out(paddr_out), 
        .pwdata_out(pwdata_out), 
        .pr_data(pr_data)
    );

    // Clock generation
    always
        #10 hclk = ~hclk;                // Toggle clock every 10 time units

    // Reset task
    task reset;
    begin
        @(negedge hclk);                  // On falling edge of clock
        hresetn = 1'b0;                   // Assert reset (active low)
        @(negedge hclk);                  // Wait for next falling edge
        hresetn = 1'b1;                   // Deassert reset
    end
    endtask

    // Test initialization
    initial begin
        hclk = 1'b0;                      // Initialize clock to 0
        reset;                            // Call reset task
        AHB.single_write;                 // Call single write task from AHB master
        // AHB.single_read;               // Commented out: Uncomment if testing read instead of write
    end
endmodule
