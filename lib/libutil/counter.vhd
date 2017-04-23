library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libbase.all;

entity counter is
  generic(WIDTH: integer := 16);
  port(
    clk, reset: in std_logic;
    tick: out std_logic
  );
end counter;

architecture arch of counter is
  signal counter_reg, counter_next: unsigned(WIDTH-1 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      counter_reg <= (others=>'0');
    elsif rising_edge(clk) then
      counter_reg <= counter_next;
    end if;
  end process;

  counter_next <= counter_reg + 1;

  tick <= '1' when counter_reg = 0 else '0';
end arch;
