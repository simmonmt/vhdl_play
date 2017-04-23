library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libbase.all;

entity mod_counter is
  generic(MODVAL: integer := 16);
  port(
    clk, reset: in std_logic;
    tick: out std_logic
  );
end mod_counter;

architecture arch of mod_counter is
  constant NBITS: integer := log2ceil(MODVAL);
  signal counter_reg, counter_next: unsigned(NBITS-1 downto 0);
  signal wrap_counter: std_logic;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      counter_reg <= (others=>'0');
    elsif rising_edge(clk) then
      counter_reg <= counter_next;
    end if;
  end process;

  wrap_counter <= '1' when counter_reg = MODVAL-1 else '0';

  counter_next <= (others=>'0') when wrap_counter = '1' else
                  counter_reg + 1;

  tick <= wrap_counter;
end arch;
