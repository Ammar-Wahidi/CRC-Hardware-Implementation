module CRC #(parameter DATA_WIDTH = 16, DIV_WIDTH =5 ) (
input                                   clk                         ,
input                                   rst_n                       ,
input                                   valid_in                    ,
input   [DATA_WIDTH-1:0]                data                        ,
input   [DIV_WIDTH-1:0]                 divisor                     ,
output  [DATA_WIDTH+DIV_WIDTH-2:0]      crc_data                    ,
output                                  valid_out 
);

wire                                    data_shift_complete         ;
wire                                    A_B_1                       ;
wire                                    A_B_2                       ;
wire    [DIV_WIDTH-2:0]                 C_next                      ;

reg     [DATA_WIDTH-1:0]                data_reg                    ;
reg     [DATA_WIDTH+DIV_WIDTH-2:0]      crc_data_reg                ;
reg     [DIV_WIDTH-2:0]                 C_reg                       ;  

CRC_counter #(DATA_WIDTH,DIV_WIDTH) counter (
.clk(clk)                                                           ,
.rst_n(rst_n)                                                       ,
.valid_in(valid_in)                                                 ,    
.data_shift_complete(data_shift_complete)                           ,
.done(valid_out)
);

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        data_reg        <= 0    ;
        crc_data_reg    <= 0    ;
    end
    else if (valid_in)
    begin
        data_reg        <= data ;
        crc_data_reg    <= 0    ;
    end
    else 
    begin
        data_reg        <= data_reg << 1'b1         ;
        crc_data_reg    <= {crc_data_reg,A_B_1}     ;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
        C_reg       = 0         ;
    else if (valid_in)
        C_reg       = 0         ; 
    else
    begin
        C_reg       = C_next    ;
    end
end


assign A_B_1 = (data_shift_complete)? C_reg[DIV_WIDTH-2]:data_reg[DATA_WIDTH-1];
assign A_B_2 = (data_shift_complete)? 1'b0:(data_reg[DATA_WIDTH-1]^C_reg[DIV_WIDTH-2]);
genvar i;
generate
    for (i = 1; i< DIV_WIDTH-1;i=i+1)
        begin
            assign C_next[i] = (divisor[i])? (A_B_2^C_reg[i-1]):C_reg[i-1] ;
        end
endgenerate
assign C_next[0] = A_B_2;

assign crc_data = crc_data_reg ;



endmodule