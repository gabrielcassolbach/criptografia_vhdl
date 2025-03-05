-- NOT USED ANYMORE, KEPT FOR TESTING OF COMPLEX NUMBERS

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use work.utils_pkg.all;

entity butterfly_tb is
end entity;

architecture rtl of butterfly_tb is
    component butterfly
        port(
            inA     : in  complex_t;
            inB     : in  complex_t;
            tw      : in  complex_t;
            outA    : out complex_t;
            outB    : out complex_t
        );
    end component;

    signal inA, inB, tw, outA, outB : complex_t;
    signal outA_r, outA_i, outB_r, outB_i : sfixed(15 downto -16);
    constant period : time := 10 ns;

begin
    uut : butterfly
        port map(
            inA     => inA,
            inB     => inB,
            tw      => tw,
            outA    => outA,
            outB    => outB
        );

    outA_r <= outA.re;
    outA_i <= outA.im;
    outB_r <= outB.re;
    outB_i <= outB.im;

    tb_proc : process
    variable inA_v, inB_v, tw_v : complex_t;
    begin
        -- Test 1
        -- inA : 0+0i ; inB : 0+0i ; tw : 1+0i
        -- outA : 0+0i ; outB : 0+0i
        inA <= cmplx(0, 0);
        inB <= cmplx(0, 0);
        tw <= cmplx(0, 0);
        wait for period;

        -- Test 2
        -- inA : 1+0i ; inB : 1+0i ; tw : 1+0i
        -- outA : 2+0i ; outB : 0+0i
        inA <= cmplx(1, 0);
        inB <= cmplx(1, 0);
        tw <= cmplx(1, 0);
        wait for period;

        -- Test 3
        -- inA : 1+1i ; inB : 1+1i ; tw : 1+0i
        -- outA : 2+2i ; outB : 0+0i
        inA <= cmplx(1, 1);
        inB <= cmplx(1, 1);
        tw <= cmplx(1, 0);
        wait for period;

        -- Test 4
        -- inA : 1+1i ; inB : 1-1i ; tw : 1+0i
        -- outA : 2+0i ; outB : 0+0i
        inA <= cmplx(1, 1);
        inB <= cmplx(1, -1);
        tw <= cmplx(1, 0);
        wait for period;

        -- Test 5
        -- inA : 1+1i ; inB : 1-1i ; tw : 0+1i
        -- outA : 0+2i ; outB : 0+0i
        inA <= cmplx(1, 1);
        inB <= cmplx(1, -1);
        tw <= cmplx(0, 1);
        wait for period;

        -- Test 6
        -- inA : 2+3i ; inB : 4-1i ; tw : 1+0i
        -- outA : 6+2i ; outB : -2+4i
        inA <= cmplx(2, 3);
        inB <= cmplx(4, -1);
        tw <= cmplx(1, 0);
        wait for period;

        -- Test 7
        -- inA : 2+3i ; inB : 4-1i ; tw : 0+1i
        -- outA : 3+7i ; outB : 1-1i
        inA <= cmplx(2, 3);
        inB <= cmplx(4, -1);
        tw <= cmplx(0, 1);
        wait for period;

        -- Test 8
        -- inA : 2+3i ; inB : 4-1i ; tw : 1+1i
        -- outA : 7+6i ; outB : -3+0i
        inA <= cmplx(2, 3);
        inB <= cmplx(4, -1);
        tw <= cmplx(1, 1);
        wait for period;

        -- Test 9
        -- inA : 3-2i ; inB : 3+2i ; tw : 1+1i
        -- outA : 4+3i ; outB : 2-7i
        inA <= cmplx(3, -2);
        inB <= cmplx(3, 2);
        tw <= cmplx(1, 1);
        wait for period;

        -- Test 10
        -- inA : 4+4i ; inB : 3-5i ; tw : 6+2i
        -- outA : 32-20i ; outB : -24+28i
        inA <= cmplx(4, 4);
        inB <= cmplx(3, -5);
        tw <= cmplx(6, 2);
        wait for period;

        wait;
    end process tb_proc;

end architecture rtl;