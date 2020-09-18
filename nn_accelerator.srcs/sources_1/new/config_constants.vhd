package config_constants is 

    constant DATA_WIDTH     : positive := 8;
    
    constant MAX_KERN_DIM   : positive := 3;  -- #rows = #columns
    
    constant MAX_MAP_DIM    : positive := 13;  -- #rows = #columns
    
    constant MAX_N_CHANNELS : positive := 128;

    -- Convolution kernels parameters
    constant MAX_KERN_ROWS  : natural := 3;
    constant MAX_BITS_KERN_ROWS : natural;
    constant MAX_KERN_COLUMNS : natural := 3;
    constant MAX_BITS_KERN_COLUMNS : natural;
    constant MAX_KERN_SIZE  : natural := MAX_KERN_ROWS * MAX_KERN_COLUMNS;
    constant MAX_BITX_KERN_SIZE : natural;

    -- Convolution maps parameters
    constant MAX_MAP_ROWS   : natural := 255;
    constant MAX_BITS_MAP_ROWS : natural;
    constant MAX_MAP_COLUMNS : natural := 255;
    constant MAX_BITS_MAP_COLUMNS : natural;
    constant MAX_MAP_SIZE   : natural := MAX_MAP_ROWS * MAX_MAP_COLUMNS;
    constant MAX_BITS_MAP_SIZE : natural;

    -- Convolution channels parameters
    constant MAX_CHANNELS   : natural := 1023;
    constant MAX_BITS_CHANNELS : natural;

    -- Fully connected layers parameters
    constant MAX_FC_WEIGHTS : natural := 511;
    constant MAX_BITS_FC_WEIGHTS : natural;
    constant MAX_FC_NEURONS : natural := 3;
    constant MAX_BITS_FC_NEURONS : natural;
    
end;

package body config_constants is

    -- Returns number of bits required to represent val in binary vector
    function bits_to_represent(val : natural) return natural is
        variable v_res    : natural;  -- Result
        variable v_remain : natural;  -- Remainder used in iteration
    begin
        v_res := 0;
        v_remain := val;
        while v_remain > 0 loop  -- Iteration for each bit required
            v_res := v_res + 1;
            v_remain := v_remain / 2;
        end loop;
        return v_res;
    end function;
    
    constant MAX_BITS_KERN_ROWS : natural := bits_to_represent(MAX_KERN_ROWS);
    constant MAX_BITS_KERN_COLUMNS : natural := bits_to_represent(MAX_KERN_COLUMNS);
    constant MAX_BITX_KERN_SIZE : natural := bits_to_represent(MAX_KERN_SIZE);
    constant MAX_BITS_MAP_ROWS : natural := bits_to_represent(MAX_MAP_ROWS);
    constant MAX_BITS_MAP_COLUMNS : natural := bits_to_represent(MAX_MAP_COLUMNS);
    constant MAX_BITS_MAP_SIZE : natural := bits_to_represent(MAX_MAP_SIZE);
    constant MAX_BITS_CHANNELS : natural := bits_to_represent(MAX_CHANNELS);
    constant MAX_BITS_FC_WEIGHTS : natural := bits_to_represent(MAX_FC_WEIGHTS);
    constant MAX_BITS_FC_NEURONS : natural := bits_to_represent(MAX_FC_NEURONS);

    --constant MAX_BITS_FC_WEIGHTS : natural := 9;
    --constant MAX_BITS_FC_NEURONS : natural := 2;

end;
