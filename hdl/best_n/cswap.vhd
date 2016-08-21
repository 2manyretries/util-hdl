
-- cswapa
-- Conditionally Swap the pair of inputs to an ordered pair of outputs.
--
-- The comparison is done over a subrange (up to the full range) of the data
-- width, which allows for the sort-key to be combined with other data.
-- (For example an index of which element in the stream.)
-- Data outside the sort-key is considered a black box and passed around
-- untouched with it.
--
-- We also admit less-than (best is smallest) or greater-or-equal (best is
-- largest comparisons).
--
-- (c) GIves (2manyretries) 2016
-- 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cswap is
  generic (
    width : positive;  -- datum width
    msb   : natural;   -- msbit to compare
    lsb   : natural;   -- lsbit to compare
    lt    : boolean    -- whether to compare less-than (best is smallest)
  );
  port (
    ina  : in    std_logic_vector(width-1 downto 0);
    inb  : in    std_logic_vector(width-1 downto 0);
    outa :   out std_logic_vector(width-1 downto 0);
    outb :   out std_logic_vector(width-1 downto 0)
  );
end entity cswap;

architecture rtl of cswap is
begin

  p_cswap : process (ina,inb) is
  begin
    outa <= ina;
    outb <= inb;
    if lt = ( unsigned(ina(msb downto lsb)) < unsigned(inb(msb downto lsb)) ) then
      outa <= inb;
      outb <= ina;
    end if;
  end process p_cswap;

end architecture rtl;
