library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libuart.all;
use simmonmt.libutil.all;

entity echo is
  port(
    clk: in std_logic;
    dbg: out std_logic_vector(7 downto 0);
    ser_rxd: in std_logic;
    ser_txd: out std_logic
  );
end echo;

architecture arch of echo is
  type state_type is (init, init2, waitrecv, send);
  signal state_reg, state_next: state_type;

  signal reset: std_logic;
  signal uart_rd, uart_wr, uart_rd_empty, uart_wr_full: std_logic;
  signal data_reg, data_next: std_logic_vector(7 downto 0);
  signal uart_rd_data: std_logic_vector(7 downto 0);
begin
  dbg <= (others=>'1');

  startup_unit: startup
    port map(clk=>clk, reset=>reset);

  uart_unit: uart
    port map(clk=>clk, reset=>reset,
             rd_uart=>uart_rd, wr_uart=>uart_wr,
             r_data=>uart_rd_data, w_data=>data_reg,
             rd_empty=>uart_rd_empty, wr_full=>uart_wr_full,
             rx=>ser_rxd, tx=>ser_txd);

  process(clk, reset)
  begin
    if reset = '1' then
      state_reg <= init;
      data_reg <= (others=>'0');
    elsif rising_edge(clk) then
      state_reg <= state_next;
      data_reg <= data_next;
    end if;
  end process;

  process(state_reg, uart_rd_empty, uart_wr_full, data_reg, uart_rd_data)
  begin
    state_next <= state_reg;
    data_next <= data_reg;
    uart_rd <= '0';
    uart_wr <= '0';

    case state_reg is
      when init =>
        -- send 'R'
        data_next <= std_logic_vector(to_unsigned(82, 8));
        state_next <= init2;
      when init2 =>
        uart_wr <= '1';
        state_next <= waitrecv;
      when waitrecv =>
        if uart_rd_empty = '0' then
          data_next <= uart_rd_data;
          uart_rd <= '1';
          state_next <= send;
        end if;
      when send =>
        if uart_wr_full = '0' then
          uart_wr <= '1';
          state_next <= waitrecv;
        end if;
    end case;
  end process;
end arch;
