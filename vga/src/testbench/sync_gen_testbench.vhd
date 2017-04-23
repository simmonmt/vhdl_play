library ieee;
use ieee.std_logic_1164.all;

entity sync_gen_testbench is
end sync_gen_testbench;

architecture tb_arch of sync_gen_testbench is
  constant T: time := 20 ns;
  signal clk, reset: std_logic;
  signal htick, vtick: std_logic;
begin
  uut: entity work.sync_gen
    port map(clk=>clk, reset=>reset, htick=>htick, vtick=>vtick);

  process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;

  process
  begin
    reset <= '1';
    wait until falling_edge(clk);
    wait until falling_edge(clk);
    reset <= '0';

    wait for 100 us;

    assert false
      report "done"
      severity failure;
  end process;
end tb_arch;
