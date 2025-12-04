module CRC_tb ();
parameter       DATA_WIDTH = 10         ;
parameter       DIV_WIDTH = 6           ;

reg                                 clk                     ;
reg                                 rst_n                   ;
reg                                 valid_in                ;
reg [DATA_WIDTH-1:0]                data                    ;
reg [DIV_WIDTH-1:0]                 divisor                 ;
wire [DATA_WIDTH+DIV_WIDTH-2:0]     crc_data                ;
wire valid_out;


integer test_num;
reg [DATA_WIDTH+DIV_WIDTH-2:0] expected_crc;

CRC #(DATA_WIDTH, DIV_WIDTH) crc (
.clk(clk)                   ,
.rst_n(rst_n)               ,
.valid_in(valid_in)         ,
.data(data)                 ,
.divisor(divisor)           ,
.crc_data(crc_data)         ,
.valid_out(valid_out)
);

initial clk = 0;
always #5 clk = ~clk;

// Task to run a single test
task run_test;
    input [DATA_WIDTH-1:0] test_data;
    input [DIV_WIDTH-1:0] test_divisor;
    input [DATA_WIDTH+DIV_WIDTH-2:0] expected;
    input [200*8-1:0] test_name;
    begin
        test_num = test_num + 1;
        $display("\n=== Test %0d: %s ===", test_num, test_name);
        $display("Data:     %b (%0d)", test_data, test_data);
        $display("Divisor:  %b (%0d)", test_divisor, test_divisor);
        $display("Expected: %b", expected);
        
        @(posedge clk);
        valid_in = 1;
        data = test_data;
        divisor = test_divisor;
        
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        
        $display("Got:      %b", crc_data);
        
        if (crc_data === expected) begin
            $display("*** PASS ***");
        end else begin
            $display("*** FAIL ***");
            $display("ERROR: CRC mismatch!");
        end
        
        #20;
    end
endtask

initial begin
    // Initialize
    rst_n = 0;
    valid_in = 0;
    data = 0;
    divisor = 0;
    test_num = 0;
    
    #15;
    rst_n = 1;
    #10;
    
    // Test 1: Original test case
    // Data: 1010001101, Divisor: 110101
    run_test(
        10'b1010001101,
        6'b110101,
        15'b101000110101110,  
        "Original test case"
    );
    
    // Test 2: Simple case - all zeros data
    // Data: 0000000000, Divisor: 110101
    // Expected CRC: 00000
    run_test(
        10'b0000000000,
        6'b110101,
        15'b000000000000000,  // Expected: 00000
        "All zeros data"
    );
    
    // Test 3: All ones data
    // Data: 1111111111, Divisor: 110101
    run_test(
        10'b1111111111,
        6'b110101,
        15'b111111111101100,  // Expected: calculated via MATLAB
        "All ones data"
    );
    
    // Test 4: Single bit set
    // Data: 1000000000, Divisor: 110101
    run_test(
        10'b1000000000,
        6'b110101,
        15'b100000000011010,  // Expected: calculated via MATLAB
        "Single MSB bit"
    );
    
    // Test 5: Pattern with CRC-5
    // Data: 1100110011, Divisor: 110101
    run_test(
        10'b1100110011,
        6'b110101,
        15'b110011001100011,  // calculated via MATLAB
        "Alternating pattern"
    );

    // Test 6
    // Data: 1010001101, Divisor: 111111
    run_test(
        10'b1010001101,
        6'b111111,
        15'b101000110111100,  // calculated via MATLAB
        "Divisor all ones"
    );

    // Test 7
    // Data: 1010001101, Divisor: 111111
    run_test(
        10'b1011101101,
        6'b101101,
        15'b101110110110011,  // calculated via MATLAB
        "Divisor all ones"
    );
    

    $display("\n=== All Tests Complete ===");
    $display("Total tests run: %0d", test_num);
    
    #50;
    $finish;
end



endmodule