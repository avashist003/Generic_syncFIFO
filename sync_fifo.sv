// 
// Generic synchronous FIFO
// Depth may or may not be power of 2
//
// Implememtation logic:
// Correctly wrap the write and read pointers based on the depth.
//

module sync_fifo_sv #(WIDTH = 8,
                    DEPTH = 4
    )(
    input  logic clk,
    input  logic rst_n,
    input  logic wr_en_i,
    input  logic [WIDTH-1:0] wr_data_i,
    output logic full_o,
    input  logic rd_en_i,
    output logic [WIDTH-1:0] rd_data_o,
    output logic empty_o
  );

    // creating a local parameter for the depth MSB
    localparam MSB = $clog2(DEPTH);

    // Instantiating a 2d Memory block for the FIFO
    logic [WIDTH-1:0] mem [DEPTH-1:0];
  
    // Write and Read pointers
    // Need an extra bit for full/empty
    logic [MSB:0] wr_ptr, rd_ptr;

    // Empty logic
    assign empty_o = (wr_ptr == rd_ptr);
    // FUll logic
    assign full_o = (wr_ptr[MSB]^rd_ptr[MSB]) && (wr_ptr[MSB-1:0] == rd_ptr[MSB-1:0]);

    always_ff@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end
        // Wrap the pointer when reached the required depth
        // toggle the MSB bit of pointer for correct full/empty flags
        else if (wr_en_i && !full_o) begin
            if (wr_ptr[MSB-1:0] == DEPTH-1) begin
                wr_ptr[MSB-1:0] <= '0;
                wr_ptr[MSB] <= ~wr_ptr[MSB];
            end
            else begin
                wr_ptr <= wr_ptr + 1;
            end
            // Write the data to memory
            mem[wr_ptr[MSB-1:0]] <= wr_data_i;
        end
    end

    always_ff@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= '0;
        end
        else if (rd_en_i && !empty_o) begin
            if (rd_ptr[MSB-1:0] == DEPTH-1) begin
                rd_ptr[MSB-1:0] <= '0;
                rd_ptr[MSB] <= ~rd_ptr[MSB];
            end
            else begin
                rd_ptr <= rd_ptr + 1;
            end
        end
    end
    // Read the data out combinationally
    assign rd_data_o = mem[rd_ptr[MSB-1:0]];

endmodule  
