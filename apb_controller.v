module apb_controller(
    input hclk,             // Clock input
    input hresetn,          // Active low reset
    input hwrite_reg,       // Latched write signal
    input hwrite_reg1,      // Further latched write signal
    input hwrite,           // Write signal
    input valid,            // Valid signal from AHB interface
    input [31:0] haddr,     // Address from AHB interface
    input [31:0] hwdata,    // Write data from AHB interface
    input [31:0] hwdata1,   // Pipelined write data
    input [31:0] hwdata2,   // Second stage pipelined write data
    input [31:0] haddr1,    // Pipelined address
    input [31:0] haddr2,    // Second stage pipelined address
    input [31:0] pr_data,   // Processor data (not used in this module)
    input [2:0] temp_sel,   // Selection signal based on AHB address

    output reg penable,     // Enable signal for APB interface
    output reg pwrite,      // Write signal for APB interface
    output reg hr_readyout, // Ready signal to AHB interface
    output reg [2:0] psel,  // Select signal for APB peripherals
    output reg [31:0] paddr, // Address for APB interface
    output reg [31:0] pwdata // Write data for APB interface
);

// Define present and next state registers
reg [2:0] present, next;

// State encoding for FSM
parameter ST_IDLE    = 3'b000,
          ST_WWAIT   = 3'b001,
          ST_READ    = 3'b010,
          ST_RENABLE = 3'b011,
          ST_WRITE   = 3'b100,
          ST_WRITEP  = 3'b101,
          ST_WENABLE = 3'b110,
          ST_WENABLEP= 3'b111;

// Temporary variables to hold output values
reg penable_temp, pwrite_temp, hr_readyout_temp;
reg [2:0] psel_temp;
reg [31:0] paddr_temp, pwdata_temp;

// Present state logic: Update present state on clock edge
always @(posedge hclk) begin
    if (!hresetn)
        present <= ST_IDLE; // Reset to IDLE state
    else
        present <= next;    // Move to next state
end

// Next state logic based on the current state and input conditions
always @(*) begin
    next = ST_IDLE; // Default next state is IDLE
    case (present)
        ST_IDLE:    if (valid && hwrite) next = ST_WWAIT;   // Move to write wait state
                    else if (valid && !hwrite) next = ST_READ;  // Move to read state
                    else next = ST_IDLE;

        ST_READ:    next = ST_RENABLE;  // After read, move to re-enable state

        ST_RENABLE: if (valid && hwrite) next = ST_WWAIT;   // Transition to write wait
                    else if (valid && !hwrite) next = ST_READ; // Continue reading
                    else next = ST_IDLE;  // Return to idle

        ST_WRITE:   if (valid) next = ST_WENABLEP; // Write enable with pipeline
                    else next = ST_WENABLE; // Write enable

        ST_WRITEP:  next = ST_WENABLEP; // Write enable for pipelined

        ST_WWAIT:   if (valid) next = ST_WRITEP;  // Move to pipelined write
                    else next = ST_WRITE;   // Regular write

        ST_WENABLE: if (valid && !hwrite) next = ST_READ;  // Return to read
                    else next = ST_IDLE;  // Go to idle

        ST_WENABLEP: if (valid && hwrite_reg) next = ST_WRITEP;  // Pipelined write
                     else if (!valid && hwrite_reg) next = ST_WRITE;
                     else if (!hwrite) next = ST_READ; // Return to read
    endcase
end

// Temporary output logic based on current state
always @(*) begin
    case (present)
        ST_IDLE:    if (valid && !hwrite) begin
                        paddr_temp = haddr;          // Address for APB
                        pwrite_temp = hwrite;        // Set write signal
                        psel_temp = temp_sel;        // Select the peripheral
                        penable_temp = 0;            // Disable enable signal
                        hr_readyout_temp = 0;        // Not ready yet
                    end else if (valid && hwrite) begin
                        psel_temp = 0;               // De-select peripherals
                        penable_temp = 0;            // Disable enable signal
                        hr_readyout_temp = 1;        // Ready for the next operation
                    end else begin
                        psel_temp = 0;
                        penable_temp = 0;
                        hr_readyout_temp = 1;
                    end

        ST_READ:    begin
                        penable_temp = 1;            // Enable the APB transfer
                        hr_readyout_temp = 1;        // Indicate ready to AHB
                    end

        ST_RENABLE: if (valid && !hwrite) begin
                        paddr_temp = haddr;          // Address for APB
                        pwrite_temp = hwrite;        // Set write signal
                        psel_temp = temp_sel;        // Select the peripheral
                        penable_temp = 0;            // Disable enable signal
                        hr_readyout_temp = 0;        // Not ready yet
                    end else if (valid && hwrite) begin
                        psel_temp = 0;               // De-select peripherals
                        penable_temp = 0;            // Disable enable signal
                        hr_readyout_temp = 1;        // Ready for the next operation
                    end else begin
                        psel_temp = 0;
                        penable_temp = 0;
                        hr_readyout_temp = 1;
                    end

        ST_WWAIT:   begin
                        paddr_temp = haddr1;         // Use pipelined address
                        pwdata_temp = hwdata;        // Write data
                        pwrite_temp = hwrite;        // Write enable signal
                        psel_temp = temp_sel;        // Select the peripheral
                        penable_temp = 0;            // Disable enable signal
                        hr_readyout_temp = 0;        // Not ready yet
                    end

        ST_WRITE, ST_WRITEP: begin
                        penable_temp = 1;            // Enable APB write
                        hr_readyout_temp = 1;        // Ready for the next operation
                    end

        ST_WENABLEP: begin
                        paddr_temp = haddr2;         // Use second stage pipelined address
                        pwdata_temp = hwdata1;       // Use first stage pipelined data
                        pwrite_temp = hwrite_reg;    // Latched write enable
                        psel_temp = temp_sel;        // Select the peripheral
                        penable_temp = 0;            // Disable enable signal
                        hr_readyout_temp = 0;        // Not ready yet
                    end

        ST_WENABLE: if (valid && !hwrite) begin
                        paddr_temp = haddr2;         // Use second stage pipelined address
                        pwrite_temp = hwrite;        // Set write signal
                        psel_temp = temp_sel;        // Select the peripheral
                        penable_temp = 0;            // Disable enable signal
                        hr_readyout_temp = 0;        // Not ready yet
                    end else if (valid && hwrite) begin
                        psel_temp = 0;               // De-select peripherals
                        penable_temp = 0;            // Disable enable signal
                        hr_readyout_temp = 1;        // Ready for the next operation
                    end else begin
                        psel_temp = 0;
                        penable_temp = 0;
                        hr_readyout_temp = 1;
                    end
    endcase
end

// Actual output logic updated on clock edge
always @(posedge hclk) begin
    if (!hresetn) begin
        paddr <= 0;
        pwdata <= 0;
        pwrite <= 0;
        psel <= 0;
        penable <= 0;
        hr_readyout <= 1;  // Default to ready
    end else begin
        paddr <= paddr_temp;
        pwdata <= pwdata_temp;
        pwrite <= pwrite_temp;
        psel <= psel_temp;
        penable <= penable_temp;
        hr_readyout <= hr_readyout_temp;
    end
end

endmodule
