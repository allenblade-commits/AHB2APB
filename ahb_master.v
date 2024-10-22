module ahb_master(
    input hclk,             // Clock input
    input hresetn,          // Active low reset
    input hr_readyout,       // Ready output from slave
    input [31:0] hr_data,   // Data received from the slave
    output reg [31:0] haddr, // Address to send to the slave
    output reg [31:0] hwdata, // Write data to send to the slave
    output reg hwrite,       // Write enable signal
    output reg hready_in,    // Ready input signal
    output reg [1:0] htrans  // Transaction type signal
);

reg [2:0] hburst; // Burst type: single, 4-beat, 16-beat, etc.
reg [2:0] hsize;  // Data size: 8-bit, 16-bit, 32-bit
integer i = 0;    // Loop counter

// Task for single write transaction
task single_write();
begin
    // Set write, htrans, and hsize on clock edge
    @(posedge hclk);
    #1;
    begin
        hwrite = 1;            // Enable write
        htrans = 2'd2;         // Non-sequential transaction
        hsize = 0;             // 8-bit data size
        hburst = 0;            // Single transfer
        hready_in = 1;         // Ready to proceed
        haddr = 32'h8000_0000; // Address to write to
    end

    // Set write data on next clock edge
    @(posedge hclk);
    #1;
    begin
        hwdata = 32'h24;       // Data to write
        htrans = 2'd0;         // End of transaction
    end
end
endtask

// Task for single read transaction
task single_read();
begin
    // Set read, htrans, and hsize on clock edge
    @(posedge hclk);
    #1;
    begin
        hwrite = 0;            // Disable write (read operation)
        htrans = 2'd2;         // Non-sequential transaction
        hsize = 0;             // 8-bit data size
        hburst = 0;            // Single transfer
        hready_in = 1;         // Ready to proceed
        haddr = 32'h8000_0000; // Address to read from
    end

    // End the transaction on next clock edge
    @(posedge hclk);
    #1;
    begin
        htrans = 2'd0;         // End of transaction
    end
end
endtask

// Task for burst write with 4 transfers
task burst_4_incr_write();
begin
    // Start the burst write on clock edge
    @(posedge hclk);
    #1;
    begin
        hwrite = 1;            // Enable write
        htrans = 2'd2;         // Non-sequential transaction
        hsize = 0;             // 8-bit data size
        hburst = 3'd1;         // Incrementing burst of 4
        hready_in = 1;         // Ready to proceed
        haddr = 32'h8000_0000; // Start address
    end

    // First transfer in the burst
    @(posedge hclk);
    #1;
    begin
        haddr = haddr + 1;     // Increment address
        hwdata = {$random} % 256; // Random data to write
        htrans = 2'd3;         // Sequential transaction
    end

    // Loop for the next two transfers in the burst
    for (i = 0; i < 2; i = i + 1) begin
        @(posedge hclk);
        #1;
        begin
            haddr = haddr + 1; // Increment address
            hwdata = {$random} % 256; // Random data
            htrans = 2'd3;     // Sequential transaction
        end
        @(posedge hclk);       // Wait for next clock edge
    end

    // Final transfer in the burst
    @(posedge hclk);
    #1;
    begin
        hwdata = {$random} % 256; // Random data
        htrans = 2'd0;         // End of transaction
    end
end
endtask

endmodule
