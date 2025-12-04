function [crc_result, full_output] = crc_calculator(data, divisor, verbose)
% CRC_CALCULATOR - Calculate CRC (Cyclic Redundancy Check) using polynomial division
%
% Inputs:
%   data     - Binary array or decimal number representing the data
%   divisor  - Binary array or decimal number representing the divisor polynomial
%              Must start and end with 1 (e.g., [1 1 0 1 0 1])
%   verbose  - (optional) If true, displays step-by-step calculation
%
% Outputs:
%   crc_result  - The CRC remainder as a binary array
%   full_output - The complete output (data + CRC) as a binary array
%
% Example:
%   data = [1 0 1 0 0 0 1 1 0 1];
%   divisor = [1 1 0 1 0 1];
%   [crc, full] = crc_calculator(data, divisor, true);

    if nargin < 3
        verbose = false;
    end
    
    % Convert inputs to binary arrays if they're decimal numbers
    if ~islogical(data) && length(data) == 1
        data = dec2bin_array(data);
    end
    
    if ~islogical(divisor) && length(divisor) == 1
        divisor = dec2bin_array(divisor);
    end
    
    % Validate divisor format (must start and end with 1)
    if divisor(1) ~= 1 || divisor(end) ~= 1
        error('Divisor must start and end with 1');
    end
    
    data_width = length(data);
    div_width = length(divisor);
    crc_width = div_width - 1;
    
    % Append zeros to data (for CRC calculation)
    augmented_data = [data, zeros(1, crc_width)];
    
    if verbose
        fprintf('\n=== CRC Calculation ===\n');
        fprintf('Data:        ');
        fprintf('%d', data);
        fprintf(' (length: %d)\n', data_width);
        fprintf('Divisor:     ');
        fprintf('%d', divisor);
        fprintf(' (length: %d)\n', div_width);
        fprintf('Augmented:   ');
        fprintf('%d', augmented_data);
        fprintf('\n\n');
    end
    
    % Perform polynomial division
    remainder = augmented_data;
    
    for i = 1:(data_width + crc_width - div_width + 1)
        if verbose
            fprintf('Step %d: ', i);
            fprintf('%d', remainder);
            fprintf('\n');
        end
        
        % If MSB is 1, perform XOR with divisor
        if remainder(i) == 1
            for j = 1:div_width
                remainder(i + j - 1) = xor(remainder(i + j - 1), divisor(j));
            end
            
            if verbose
                fprintf('        XOR with divisor\n');
            end
        else
            if verbose
                fprintf('        Skip (MSB is 0)\n');
            end
        end
    end
    
    % Extract CRC (last crc_width bits)
    crc_result = remainder(end - crc_width + 1:end);
    
    % Full output is original data + CRC
    full_output = [data, crc_result];
    
    if verbose
        fprintf('\n=== Result ===\n');
        fprintf('CRC remainder: ');
        fprintf('%d', crc_result);
        fprintf(' (decimal: %d)\n', bin_array2dec(crc_result));
        fprintf('Full output:   ');
        fprintf('%d', full_output);
        fprintf('\n');
        fprintf('Expected Verilog output width: %d bits\n', data_width + crc_width);
    end
end

function bin_array = dec2bin_array(num)
    % Convert decimal number to binary array
    if num == 0
        bin_array = 0;
    else
        bin_str = dec2bin(num);
        bin_array = double(bin_str) - 48; % Convert '0'/'1' chars to 0/1
    end
end

function dec_num = bin_array2dec(bin_array)
    % Convert binary array to decimal number
    dec_num = 0;
    for i = 1:length(bin_array)
        dec_num = dec_num * 2 + bin_array(i);
    end
end

%% Test Cases
function run_all_tests()
    fprintf('========================================\n');
    fprintf('         CRC MATLAB TEST SUITE         \n');
    fprintf('========================================\n');
    
    % Test 1: Original test case
    fprintf('\n--- Test 1: Original Case ---\n');
    data1 = [1 0 1 0 0 0 1 1 0 1];
    div1 = [1 1 0 1 0 1];
    [crc1, full1] = crc_calculator(data1, div1, true);
    
    % Test 2: All zeros
    fprintf('\n--- Test 2: All Zeros ---\n');
    data2 = [0 0 0 0 0 0 0 0 0 0];
    div2 = [1 1 0 1 0 1];
    [crc2, full2] = crc_calculator(data2, div2, true);
    
    % Test 3: All ones
    fprintf('\n--- Test 3: All Ones ---\n');
    data3 = [1 1 1 1 1 1 1 1 1 1];
    div3 = [1 1 0 1 0 1];
    [crc3, full3] = crc_calculator(data3, div3, true);
    
    % Test 4: Single MSB
    fprintf('\n--- Test 4: Single MSB ---\n');
    data4 = [1 0 0 0 0 0 0 0 0 0];
    div4 = [1 1 0 1 0 1];
    [crc4, full4] = crc_calculator(data4, div4, true);
    
    % Test 5: CRC-5 USB (polynomial: x^5 + x^2 + 1 = 100101)
    fprintf('\n--- Test 5: CRC-5 USB ---\n');
    data5 = [1 1 0 0 1 1 0 0 1 1];
    div5 = [1 1 0 1 0 1];
    [crc5, full5] = crc_calculator(data5, div5, true);

    % Test 6
    fprintf('\n--- Test 6: CRC-5 ---\n');
    data6 = [1 0 1 0 0 0 1 1 0 1];
    div6 = [1 1 1 1 1 1];
    [crc6, full6] = crc_calculator(data6, div6, true);

    % Test 7
    fprintf('\n--- Test 7: CRC-5 ---\n');
    data7 = [1 0 1 1 1 0 1 1 0 1];
    div7 = [1 0 1 1 0 1];
    [crc7, full7] = crc_calculator(data7, div7, true);

    
    % Summary
    fprintf('\n========================================\n');
    fprintf('           TEST SUMMARY                \n');
    fprintf('========================================\n');
    fprintf('Test 1 CRC: ');
    fprintf('%d', crc1);
    fprintf('\n');
    fprintf('Test 2 CRC: ');
    fprintf('%d', crc2);
    fprintf('\n');
    fprintf('Test 3 CRC: ');
    fprintf('%d', crc3);
    fprintf('\n');
    fprintf('Test 4 CRC: ');
    fprintf('%d', crc4);
    fprintf('\n');
    fprintf('Test 5 CRC: ');
    fprintf('%d', crc5);
    fprintf('\n');
    fprintf('Test 6 CRC: ');
    fprintf('%d', crc6);
    fprintf('\n');
    fprintf('Test 7 CRC: ');
    fprintf('%d', crc7);
    fprintf('\n');
    fprintf('========================================\n');
end
