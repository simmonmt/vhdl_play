library ieee;
use ieee.std_logic_1164.all;

package libutil is
  component fifo is
    generic(
      NDATABITS: natural := 8;  -- number of bits
      NADDRBITS: natural := 4   -- number of address bits
      );
    port(
      clk, reset: in std_logic;
      rd, wr: in std_logic;
      r_data: out std_logic_vector(NDATABITS-1 downto 0);
      w_data: in std_logic_vector(NDATABITS-1 downto 0);
      empty, full: out std_logic
      );
  end component fifo;

  component mod_counter is
    generic(MODVAL: integer := 16);
    port(
      clk, reset: in std_logic;
      tick: out std_logic
      );
  end component mod_counter;

  component startup is
    port(
      clk: in std_logic;
      reset: out std_logic
      );
  end component startup;

  component falling_edge_detector is
    port(
      clk, reset: in std_logic;
      level: in std_logic;
      tick: out std_logic
      );
  end component falling_edge_detector;
end libutil;
