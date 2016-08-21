-- 
-- Select the n-best elements from a stream.
-- The n-best elements are available in sorted order n clocks after the
-- last stream element is presented.
-- They are available unsorted on the clock after the last stream element.
--
-- This is to my knowledge an original algorithm, without prior art
-- (systolic sorting is a given but I mean here the n-best cyclic use).
-- I would be interested to know if this is in fact the case (either way).
-- (c) GIves (2manyretries) 2016
--
-- Example:
-- The vertical bars with * at each end represent cswap nodes.
--                        |
--                        *
-- din >---*
--         |        +-----+
-- +>------*----*---| reg |----->+
-- |    a    b  | c +-----+      |
-- |+>-----*----*---| reg |---->+|
-- ||   a  | b    c +-----+     ||
-- ||+>----*----*---| reg |--->+||
-- |||  a    b  | c +-----+    |||
-- |||+>--------*---| reg |-->+|||
-- ||||             +-----+   ||||
-- ++++<=====================<++++===> res
--
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity best_n is
  generic (
    n     : positive;
    width : positive;
    msb   : natural;
    lsb   : natural;
    lt    : boolean
  );
  port (
    clk : in    std_logic;
    rst : in    std_logic;
    dv  : in    std_logic;
    din : in    std_logic_vector(width-1 downto 0);
    res :   out std_logic_vector(width*n-1 downto 0)
  );
end entity best_n;

architecture rtl of best_n is
  function bool2stdlogic(b:boolean) return std_logic
  is
    variable val : std_logic := '0';
  begin
    if b then
      val:='1';
    end if;
    return val;
  end function bool2stdlogic;

  constant EXTREME : std_logic_vector(width-1 downto 0) := (others => bool2stdlogic(lt));

  type bus_type is array(natural range <>) of std_logic_vector(width-1 downto 0);

  signal busa : bus_type(0 to n);
  signal busb : bus_type(0 to n);
  signal busc : bus_type(0 to n-1);
  signal reg  : bus_type(0 to n-1);

  component cswap is
  generic (
    width : positive;
    msb   : natural;
    lsb   : natural;
    lt    : boolean
  );
  port (
    ina  : in    std_logic_vector(width-1 downto 0);
    inb  : in    std_logic_vector(width-1 downto 0);
    outa :   out std_logic_vector(width-1 downto 0);
    outb :   out std_logic_vector(width-1 downto 0)
  );
  end component cswap;
begin
  a_n_is_even : assert n mod 2 = 0 report "n must be even" severity failure;

  -- Stage a gets the register outputs with the input at the top.
  busa(n)        <= din when dv='1' else EXTREME;
  busa(0 to n-1) <= reg;

  -- Stage a is not propagated to b in the following odd stage so pass it thru.
  busb(0) <= busa(0);

  -- Generate an odd followed by an even compare&swap stage.
  g_cswap : for i in 0 to n/2-1 generate
    i_cswap_odd : cswap
    generic map(
      width => WIDTH,
      msb   => MSB,
      lsb   => LSB,
      lt    => LT
    )
    port map(
      ina  => busa(2*i+2),
      inb  => busa(2*i+1),
      outa => busb(2*i+2),
      outb => busb(2*i+1)
    );
    i_cswap_even : cswap
    generic map(
      width => WIDTH,
      msb   => MSB,
      lsb   => LSB,
      lt    => LT
    )
    port map(
      ina  => busb(2*i+1),
      inb  => busb(2*i+0),
      outa => busc(2*i+1),
      outb => busc(2*i+0)
    );
  end generate g_cswap;

  -- Register the compare&swap outputs.
  p_reg : process (clk) is
  begin
    if rising_edge(clk) then
      if rst='1' then
        reg <= (others => EXTREME);
      else
        reg <= busc(0 to n-1);
      end if;
    end if;
  end process p_reg;

  g_res : for i in 0 to n-1 generate
    res(width*i+width-1 downto width*i) <= reg(i);
  end generate g_res;

end architecture rtl;


