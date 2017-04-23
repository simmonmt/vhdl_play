library ieee;
use ieee.std_logic_1164.all;

entity uart_testbench is
end uart_testbench;

architecture tb_arch of uart_testbench is
  constant T: time := 20 ns;
  constant ASCII_A: std_logic_vector(7 downto 0) := "01100001";

  signal clk, reset: std_logic;
  signal r_data, w_data: std_logic_vector(7 downto 0);
  signal rd_uart, wr_uart, rd_empty, wr_full, rx, tx: std_logic;

  procedure send_frame(byte: in std_logic_vector(7 downto 0);
                       signal level: out std_logic) is
  begin
    level <= '0'; wait for 104.167 us;  -- start bit

    for i in byte'reverse_range loop
      level <= byte(i);
      wait for 104.167 us;
    end loop;

    level <= '1'; wait for 104.167 us;  -- stop bit
  end send_frame;
begin
  uut: entity work.uart
    port map(clk=>clk, reset=>reset,
             rd_uart=>rd_uart, wr_uart=>wr_uart,
             r_data=>r_data, w_data=>w_data,
             rd_empty=>rd_empty, wr_full=>wr_full,
             rx=>rx, tx=>tx);

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
    rx <= '1';
    rd_uart <= '0';
    wr_uart <= '0';
    wait until falling_edge(clk);
    wait until falling_edge(clk);
    reset <= '0';
    wait for 1 us;

    send_frame(ASCII_A, rx);

    wait for 100 us;

    assert false
      report "Simulation complete"
      severity failure;
  end process;
end tb_arch;
