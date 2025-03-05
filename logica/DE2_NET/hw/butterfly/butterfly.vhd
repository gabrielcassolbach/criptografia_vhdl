-- NOT USED ANYMORE, KEPT FOR TESTING OF COMPLEX NUMBERS

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use work.utils_pkg.all;

entity butterfly is
    port (
        inA     : in complex_t;   -- Input A
        inB     : in complex_t;   -- Input B
        tw      : in complex_t;   -- Twiddle factor
        outA    : out complex_t;  -- Output A
        outB    : out complex_t   -- Output B
    );
end butterfly ; 

architecture rtl of butterfly is
    signal outA_sig, outB_sig, tmp_sig : complex_t;
begin


    -- Butterfly operation
    -- tmp = inB * tw
    tmp_sig <= cmplx_mul(inB, tw);
    -- outA = inA + tmp
    outA_sig <= cmplx_add(inA, tmp_sig);
    -- outB = inA - tmp
    outB_sig <= cmplx_sub(inA, tmp_sig);

    -- Merge real and imaginary parts into output signals
    outA <= outA_sig;
    outB <= outB_sig;

end architecture rtl;