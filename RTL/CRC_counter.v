module CRC_counter #(parameter DATA_WIDTH = 16, DIV_WIDTH =5 ) (
input               clk                     ,
input               rst_n                   ,
input               valid_in                ,
output              data_shift_complete     ,
output              done
);
localparam N_TICKS = DATA_WIDTH + DIV_WIDTH - 1;

reg [$clog2(N_TICKS):0] count;

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n || valid_in)
        count = 0   ;
    else 
        count = count + 1   ;
end

assign done = (count == N_TICKS);
assign data_shift_complete = (count >= DATA_WIDTH);

endmodule