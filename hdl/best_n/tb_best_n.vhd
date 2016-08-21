
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_best_n is
end entity tb_best_n;

architecture behaviour of tb_best_n is

  constant HALF_TICK : time := 5 ns;
  constant N         : positive := 6;
  constant WIDTH     : positive := 8;
  constant MSB       : natural  := WIDTH-1;
  constant LSB       : natural  := 0;
  constant LT        : boolean  := true;

  signal clk : std_logic;
  signal rst : std_logic;
  signal dv  : std_logic;
  signal din : std_logic_vector(WIDTH-1 downto 0);
  signal res : std_logic_vector(WIDTH*N-1 downto 0);

  signal run : boolean := true;

  component best_n is
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
  end component best_n;

begin
  -- uut
  i_best_n : best_n
  generic map(
    n     => N,
    width => WIDTH,
    msb   => MSB,
    lsb   => LSB,
    lt    => LT
  )
  port map(
    clk => clk,
    rst => rst,
    dv  => dv,
    din => din,
    res => res
  );

  p_clk : process
  is
  begin
    if run then
      clk <= '1';
      wait for HALF_TICK;
      clk <= '0';
      wait for HALF_TICK;
    else
      wait; --forever
    end if;
  end process p_clk;


  p_apply : process
  is
  begin
    rst <= '1';
    dv  <= '0';
    wait for 9 * HALF_TICK;
    -- 1) Count Up
    rst <= '0';
    dv  <= '1';
    din <= std_logic_vector(to_unsigned( 1, WIDTH));
    for i in 1 to 10 loop
      wait for 2 * HALF_TICK;
      din <= std_logic_vector(unsigned(din)+1);
    end loop;
    wait for 2 * HALF_TICK;
    dv <= '0';
    wait for N * 2 * HALF_TICK;
    -- Reset
    rst <= '1';
    wait for 2 * HALF_TICK;
    -- 2) Count Down
    rst <= '0';
    dv  <= '1';
    for i in 10 downto -2 loop
      wait for 2 * HALF_TICK;
      din <= std_logic_vector(unsigned(din)-1);
    end loop;
    wait for 2 * HALF_TICK;
    dv  <= '0';
    wait for N * 2 * HALF_TICK;
    -- Reset
    rst <= '1';
    wait for 2 * HALF_TICK;
    -- 3) Count Up slowed
    rst <= '0';
    din <= (others => '0');
    for i in 1 to 10 loop
      wait for 2 * HALF_TICK;
      dv  <= '1';
      din <= std_logic_vector(to_unsigned(i,WIDTH));
      wait for 2 * HALF_TICK;
      dv  <= '0';
      din <= (others => '0');
    end loop;
    wait for 2 * HALF_TICK;
    wait for N * 2 * HALF_TICK;
    -- Reset
    rst <= '1';
    wait for 2 * HALF_TICK;
    run <= false;
    wait; --forever
  end process p_apply;

end architecture behaviour;
