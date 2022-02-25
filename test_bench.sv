`timescale 1ns / 1ps

module fifo_TB();
  parameter WIDTH = 4;
  parameter DEPTH = 5;

  logic clk;
  logic rst_n;
  logic wr_en_i;
  logic [WIDTH-1:0] wr_data_i;
  logic full_o;
  logic rd_en_i;
  logic [WIDTH-1:0] rd_data_o;
  logic empty_o;
  
  initial begin
    // below two lines are used to show waveform
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  sync_fifo_sv #(WIDTH, DEPTH) DUT_fifo (
    clk,
    rst_n,
    wr_en_i,
    wr_data_i,
    full_o,
    rd_en_i,
    rd_data_o,
    empty_o
  );


  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    wr_en_i = 1'b0;
    rd_en_i = 1'b0;
    wr_data_i = 0;
    @(negedge clk) rst_n = 1'b1;

    write_task;
    #20;
    @(negedge clk);
    wr_en_i = 1'b0;
    read_task;

    #100 $finish;

  end

  always #25 clk <= ~clk;

  task write_task;
    begin
      @(negedge clk);
      wr_en_i = 1'b1;
      repeat(5)
        begin
          @(negedge clk);
          wr_data_i = $urandom($random)%16;
          @(posedge clk);
        end
    end

  endtask

  task read_task;
    begin
      @(negedge clk);
      rd_en_i = 1'b1;
      repeat(5)
        begin
          @(posedge clk);
        end
    end

  endtask

endmodule
