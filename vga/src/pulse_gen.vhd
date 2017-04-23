library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libbase.all;

entity pulse_gen is
  port(
    clk, reset: in std_logic;
    htick, vtick: out std_logic
    );
end pulse_gen;

architecture arch of pulse_gen is
  constant COUNT_MAX: integer := 1600;
  constant COUNT_WIDTH: integer := log2ceil(COUNT_MAX);
  signal count_reg, count_next: unsigned(COUNT_WIDTH-1 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      count_reg <= (others=>'0');
    elsif rising_edge(clk) then
      count_reg <= count_next;
    end if;
  end process;

  count_next <= (others=>'0') when count_reg = COUNT_MAX-1 else
                count_reg + 1;

  htick <= count_reg(0);
  --vtick <= '1' when count_reg = COUNT_MAX-1 else '0';
  vtick <= '1' when count_reg = 0 else '0';
end arch;
