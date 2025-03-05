library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use work.utils_pkg.all;

entity fft is
    port (
        clk : in std_logic;
        rst : in std_logic;
        stage : in std_logic_vector(2 downto 0);
        data_in : in complex_array(0 to 31);
        data_out : out complex_array(0 to 31)
    );
end fft; 

architecture rtl of fft is
    type integer_array is array(natural range <>) of integer;
    
    signal data_out_s : complex_array(0 to 31);

    constant twiddle_table : complex_array(0 to 79) := (
        0 => cmplx(1.0,0.0),
        1 => cmplx(1.0,0.0),
        2 => cmplx(1.0,0.0),
        3 => cmplx(1.0,0.0),
        4 => cmplx(1.0,0.0),
        5 => cmplx(1.0,0.0),
        6 => cmplx(1.0,0.0),
        7 => cmplx(1.0,0.0),
        8 => cmplx(1.0,0.0),
        9 => cmplx(1.0,0.0),
        10 => cmplx(1.0,0.0),
        11 => cmplx(1.0,0.0),
        12 => cmplx(1.0,0.0),
        13 => cmplx(1.0,0.0),
        14 => cmplx(1.0,0.0),
        15 => cmplx(1.0,0.0),
        16 => cmplx(1.0,0.0),
        17 => cmplx(0.0,-1.0),
        18 => cmplx(1.0,0.0),
        19 => cmplx(0.0,-1.0),
        20 => cmplx(1.0,0.0),
        21 => cmplx(0.0,-1.0),
        22 => cmplx(1.0,0.0),
        23 => cmplx(0.0,-1.0),
        24 => cmplx(1.0,0.0),
        25 => cmplx(0.0,-1.0),
        26 => cmplx(1.0,0.0),
        27 => cmplx(0.0,-1.0),
        28 => cmplx(1.0,0.0),
        29 => cmplx(0.0,-1.0),
        30 => cmplx(1.0,0.0),
        31 => cmplx(0.0,-1.0),
        32 => cmplx(1.0,0.0),
        33 => cmplx(0.70710678,-0.70710678),
        34 => cmplx(0.0,-1.0),
        35 => cmplx(-0.70710678,-0.70710678),
        36 => cmplx(1.0,0.0),
        37 => cmplx(0.70710678,-0.70710678),
        38 => cmplx(0.0,-1.0),
        39 => cmplx(-0.70710678,-0.70710678),
        40 => cmplx(1.0,0.0),
        41 => cmplx(0.70710678,-0.70710678),
        42 => cmplx(0.0,-1.0),
        43 => cmplx(-0.70710678,-0.70710678),
        44 => cmplx(1.0,0.0),
        45 => cmplx(0.70710678,-0.70710678),
        46 => cmplx(0.0,-1.0),
        47 => cmplx(-0.70710678,-0.70710678),
        48 => cmplx(1.0,0.0),
        49 => cmplx(0.92387953,-0.38268343),
        50 => cmplx(0.70710678,-0.70710678),
        51 => cmplx(0.38268343,-0.92387953),
        52 => cmplx(-0.0,-1.0),
        53 => cmplx(-0.38268343,-0.92387953),
        54 => cmplx(-0.70710678,-0.70710678),
        55 => cmplx(-0.92387953,-0.38268343),
        56 => cmplx(1.0,0.0),
        57 => cmplx(0.92387953,-0.38268343),
        58 => cmplx(0.70710678,-0.70710678),
        59 => cmplx(0.38268343,-0.92387953),
        60 => cmplx(-0.0,-1.0),
        61 => cmplx(-0.38268343,-0.92387953),
        62 => cmplx(-0.70710678,-0.70710678),
        63 => cmplx(-0.92387953,-0.38268343),
        64 => cmplx(1.0,0.0),
        65 => cmplx(0.98078528,-0.19509032),
        66 => cmplx(0.92387953,-0.38268343),
        67 => cmplx(0.83146961,-0.55557023),
        68 => cmplx(0.70710678,-0.70710678),
        69 => cmplx(0.55557023,-0.83146961),
        70 => cmplx(0.38268343,-0.92387953),
        71 => cmplx(0.19509032,-0.98078528),
        72 => cmplx(0.0,-1.0),
        73 => cmplx(-0.19509032,-0.98078528),
        74 => cmplx(-0.38268343,-0.92387953),
        75 => cmplx(-0.55557023,-0.83146961),
        76 => cmplx(-0.70710678,-0.70710678),
        77 => cmplx(-0.83146961,-0.55557023),
        78 => cmplx(-0.92387953,-0.38268343),
        79 => cmplx(-0.98078528,-0.19509032)
    );

    constant index_table : integer_array(0 to 79) := (
        0 => 0,
        1 => 2,
        2 => 4,
        3 => 6,
        4 => 8,
        5 => 10,
        6 => 12,
        7 => 14,
        8 => 16,
        9 => 18,
        10 => 20,
        11 => 22,
        12 => 24,
        13 => 26,
        14 => 28,
        15 => 30,
        16 => 0,
        17 => 1,
        18 => 4,
        19 => 5,
        20 => 8,
        21 => 9,
        22 => 12,
        23 => 13,
        24 => 16,
        25 => 17,
        26 => 20,
        27 => 21,
        28 => 24,
        29 => 25,
        30 => 28,
        31 => 29,
        32 => 0,
        33 => 1,
        34 => 2,
        35 => 3,
        36 => 8,
        37 => 9,
        38 => 10,
        39 => 11,
        40 => 16,
        41 => 17,
        42 => 18,
        43 => 19,
        44 => 24,
        45 => 25,
        46 => 26,
        47 => 27,
        48 => 0,
        49 => 1,
        50 => 2,
        51 => 3,
        52 => 4,
        53 => 5,
        54 => 6,
        55 => 7,
        56 => 16,
        57 => 17,
        58 => 18,
        59 => 19,
        60 => 20,
        61 => 21,
        62 => 22,
        63 => 23,
        64 => 0,
        65 => 1,
        66 => 2,
        67 => 3,
        68 => 4,
        69 => 5,
        70 => 6,
        71 => 7,
        72 => 8,
        73 => 9,
        74 => 10,
        75 => 11,
        76 => 12,
        77 => 13,
        78 => 14,
        79 => 15
    );

    constant offseted_index_table : integer_array(0 to 79) := (
        0 => 1,
        1 => 3,
        2 => 5,
        3 => 7,
        4 => 9,
        5 => 11,
        6 => 13,
        7 => 15,
        8 => 17,
        9 => 19,
        10 => 21,
        11 => 23,
        12 => 25,
        13 => 27,
        14 => 29,
        15 => 31,
        16 => 2,
        17 => 3,
        18 => 6,
        19 => 7,
        20 => 10,
        21 => 11,
        22 => 14,
        23 => 15,
        24 => 18,
        25 => 19,
        26 => 22,
        27 => 23,
        28 => 26,
        29 => 27,
        30 => 30,
        31 => 31,
        32 => 4,
        33 => 5,
        34 => 6,
        35 => 7,
        36 => 12,
        37 => 13,
        38 => 14,
        39 => 15,
        40 => 20,
        41 => 21,
        42 => 22,
        43 => 23,
        44 => 28,
        45 => 29,
        46 => 30,
        47 => 31,
        48 => 8,
        49 => 9,
        50 => 10,
        51 => 11,
        52 => 12,
        53 => 13,
        54 => 14,
        55 => 15,
        56 => 24,
        57 => 25,
        58 => 26,
        59 => 27,
        60 => 28,
        61 => 29,
        62 => 30,
        63 => 31,
        64 => 16,
        65 => 17,
        66 => 18,
        67 => 19,
        68 => 20,
        69 => 21,
        70 => 22,
        71 => 23,
        72 => 24,
        73 => 25,
        74 => 26,
        75 => 27,
        76 => 28,
        77 => 29,
        78 => 30,
        79 => 31
    );

    constant offset_table : integer_array(0 to 4) := (
        0 => 0,
        1 => 16,
        2 => 32,
        3 => 48,
        4 => 64
    );

    constant bit_reverse_table : integer_array(0 to 31) := (
        0 => 0,
        1 => 16,
        2 => 8,
        3 => 24,
        4 => 4,
        5 => 20,
        6 => 12,
        7 => 28,
        8 => 2,
        9 => 18,
        10 => 10,
        11 => 26,
        12 => 6,
        13 => 22,
        14 => 14,
        15 => 30,
        16 => 1,
        17 => 17,
        18 => 9,
        19 => 25,
        20 => 5,
        21 => 21,
        22 => 13,
        23 => 29,
        24 => 3,
        25 => 19,
        26 => 11,
        27 => 27,
        28 => 7,
        29 => 23,
        30 => 15,
        31 => 31
    );

    -- Iterative FFT function
    function fft_function(
        data_in : complex_array;
        stage : integer
    ) return complex_array is
        variable data_out : complex_array(0 to 31);
        variable twiddle : complex_t;
        variable tw_i, index_i, off_index_i : integer;
        variable index, offseted_index : integer;
    begin
        -- Bit reverse the input data if stage = 0
        if stage = 0 then
            for i in 0 to 31 loop
                data_out(bit_reverse_table(i)) := data_in(i);
            end loop;
        else
            data_out := data_in;
        end if;

        -- Perform the FFT stage
        tw_i := offset_table(stage);
        index_i := offset_table(stage);
        off_index_i := offset_table(stage);
        for i in 0 to 15 loop
            twiddle := twiddle_table(tw_i);
            tw_i := tw_i + 1;

            index := index_table(index_i);
            index_i := index_i + 1;

            offseted_index := offseted_index_table(off_index_i);
            off_index_i := off_index_i + 1;

            data_out(offseted_index) := cmplx_sub(data_out(index), cmplx_mul(data_out(offseted_index), twiddle));
            data_out(index) := cmplx_sub(cmplx_add(data_out(index),data_out(index)),data_out(offseted_index));
        end loop;

        -- Return
        return data_out;
    end function fft_function;

begin

    -- data_out <= data_out_s;

    -- data_out_s <=   fft_function(data_in, to_integer(unsigned(stage))-1) when (stage > "000" and (stage < "110")) else
    --                 (others => cmplx(0.0,0.0));

    data_out <= data_out_s when stage = "110" else
                (others => cmplx(0.0,0.0));

    fft_process : process(clk, rst, stage)
    begin
        if rst = '1' then
            data_out_s <= (others => cmplx(0.0,0.0));
        elsif rising_edge(clk) and (stage > "000" and (stage < "110")) then
            data_out_s <= fft_function(data_in, to_integer(unsigned(stage))-1);
        end if;
    end process fft_process;

    -- data_out_s <=   fft_function(data_in, 0) when stage = "001" else
    --                 fft_function(data_in, 1) when stage = "010" else
    --                 fft_function(data_in, 2) when stage = "011" else
    --                 fft_function(data_in, 3) when stage = "100" else
    --                 fft_function(data_in, 4) when stage = "101" else
    --                 (others => cmplx(0.0,0.0));

end architecture rtl;