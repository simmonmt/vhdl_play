library ieee;
use ieee.std_logic_1164.all;

entity falling_edge_detector is
  port(
    clk, reset: in std_logic;
    level: in std_logic;
    tick: out std_logic
  );
end falling_edge_detector;

-- A detector that explicitly separates register updates from combinatorial
-- logic. Performance is the same as the logicinprocess architecture below.
architecture arch of falling_edge_detector is
  signal last_reg, level_reg: std_logic;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      last_reg <= '0';
      level_reg <= '0';
    elsif rising_edge(clk) then
      last_reg <= level_reg;
      level_reg <= level;
    end if;
  end process;

  tick <= last_reg and not level_reg;
end arch;
