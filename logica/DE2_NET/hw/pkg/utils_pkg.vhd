library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use work.fixed_pkg.all;

package utils_pkg is
    type complex_t is record
        re : sfixed(6 downto -9) ;
        im : sfixed(6 downto -9) ;
    end record ;

    type complex_array is array (natural range <>) of complex_t ;

    function cmplx_add (a, b : complex_t) return complex_t ;
    function cmplx_sub (a, b : complex_t) return complex_t ;
    function cmplx_mul (a, b : complex_t) return complex_t ;
    function cmplx_split (a : complex_t) return std_logic_vector;
    function cmplx (re, im : sfixed (6 downto -9)) return complex_t ;
    function cmplx (re, im : real) return complex_t ;
    function cmplx (re, im : integer) return complex_t ;

    type stdlv32_array is array (natural range <>) of std_logic_vector(31 downto 0);

    function stdlv32arr_to_cmplxarr (a : stdlv32_array) return complex_array ;


end package utils_pkg ;

package body utils_pkg is

    function cmplx_add (a, b : complex_t) return complex_t is
        variable c : complex_t ;
    begin
        c.re := resize(a.re + b.re, 6, -9) ;
        c.im := resize(a.im + b.im, 6, -9) ;
        return c ;
    end function cmplx_add ;

    function cmplx_sub (a, b : complex_t) return complex_t is
        variable c : complex_t ;
    begin
        c.re := resize(a.re - b.re, 6, -9) ;
        c.im := resize(a.im - b.im, 6, -9) ;
        return c ;
    end function cmplx_sub ;

    function cmplx_mul (a, b : complex_t) return complex_t is
        variable c : complex_t ;
        variable k1 : sfixed(14 downto -18) ;
    begin
        k1 := b.re * (a.re + a.im) ;
        c.re := resize(k1 - (a.im * (b.re + b.im)), 6, -9) ;
        c.im := resize(k1 + (a.re * (b.im - b.re)), 6, -9) ;
        -- c.re := resize(a.re * b.re - a.im * b.im, 6, -9) ;
        -- c.im := resize(a.re * b.im + a.im * b.re, 6, -9) ;
        -- c.re := resize(k1, 6, -9) ;
        -- c.im := to_sfixed(0.0, 6, -9) ;
        return c ;
    end function cmplx_mul ;

    function cmplx (re, im : sfixed(6 downto -9)) return complex_t is
        variable c : complex_t ;
    begin
        c.re := re ;
        c.im := im ;
        return c ;
    end function cmplx ;

    function cmplx (re, im : real) return complex_t is
        variable c : complex_t ;
    begin
        c.re := to_sfixed(re, 6, -9) ;
        c.im := to_sfixed(im, 6, -9) ;
        return c ;
    end function cmplx ;

    function cmplx (re, im : integer) return complex_t is
        variable c : complex_t ;
    begin
        c.re := to_sfixed(re, 6, -9) ;
        c.im := to_sfixed(im, 6, -9) ;
        return c ;
    end function cmplx ;

    function cmplx_split (a : complex_t) return std_logic_vector is
        variable c : std_logic_vector(31 downto 0) ;
        variable re_slice : std_logic_vector(15 downto 0) ;
        variable im_slice : std_logic_vector(15 downto 0) ;
    begin
        re_slice := to_slv(a.re) ;
        im_slice := to_slv(a.im) ;
        c := im_slice & re_slice ;
        return c ;
    end function cmplx_split ;

    function stdlv32arr_to_cmplxarr (a : stdlv32_array) return complex_array is
        variable c : complex_array (a'range) ;
        variable re_slice : std_logic_vector(15 downto 0) ;
        variable im_slice : std_logic_vector(15 downto 0) ;
    begin
        for i in a'range loop
            re_slice := a(i)(15 downto 0) ;
            im_slice := a(i)(31 downto 16) ;
            c(i).re := to_sfixed(re_slice, 6, -9) ;
            c(i).im := to_sfixed(im_slice, 6, -9) ;
        end loop ;
        return c ;
    end function stdlv32arr_to_cmplxarr ;


end package body utils_pkg ;