# Generic Depth Synchronous FIFO
## Design of a synchronous FIFO when depth of fifo memory is not a perfect power of 2
#### The implementation logic modifies how one might update the read/write pointers.
#### In my design, I wrap the pointers back to the starting address when they reach the maximum depth, along with the correct toggle of the MSB bit of the read and write pointers for the Full and Empty flags.

Update for write logic is shown below: (similarly, we can update the read pointer logic as well)
```sv
if (wr_en_i && !full_o) begin
        // Wrap the pointer when reached the required depth
        // toggle the MSB bit of pointer for correct full/empty flags
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
```
FIFO interface is shown below:
```sv
module sync_fifo_sv #(WIDTH = 8,
                      DEPTH = 4
    )(
    // system clock and active low asynchronous reset
    input  logic clk,
    input  logic rst_n,
    // write interface
    input  logic wr_en_i,
    input  logic [WIDTH-1:0] wr_data_i,
    output logic full_o,
    // read interface
    input  logic rd_en_i,
    output logic [WIDTH-1:0] rd_data_o,
    output logic empty_o
  );
```
