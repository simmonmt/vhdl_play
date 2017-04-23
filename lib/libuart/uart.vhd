library ieee;
use ieee.std_logic_1164.all;

library simmonmt;
use simmonmt.libutil.all;
use simmonmt.libuart_int.all;

entity uart is
  generic(
    BAUD_DVSR: integer := 325; -- 9600 baud 16x oversample; 50M/(9600*16)
    FIFO_WIDTH: integer := 2   -- number of addr bits in FIFO; size=2^width
  );
  port(
    clk, reset: in std_logic;

    -- the user interface
    rd_uart, wr_uart: in std_logic;  -- set to read or write
    r_data: out std_logic_vector(7 downto 0);  -- returns data on rd_uart
    w_data: in std_logic_vector(7 downto 0);   -- returns data on wr_uart
    rd_empty, wr_full: out std_logic;  -- rd/wr only if these are false

    -- hardware interface
    rx: in std_logic;                -- hardware RX (DTE->DCE)
    tx: out std_logic                -- hardware TX (DTE<-DCE)
    );
end uart;

architecture arch of uart is
  signal baud_tick: std_logic;
  signal rx_done_tick: std_logic;
  signal rx_data_out: std_logic_vector(7 downto 0);
  signal tx_fifo_out: std_logic_vector(7 downto 0);
  signal tx_empty, tx_fifo_not_empty: std_logic;
  signal tx_done_tick: std_logic;
begin
  baud_gen_unit: mod_counter
    generic map(MODVAL=>BAUD_DVSR)
    port map(clk=>clk, reset=>reset, tick=>baud_tick);

  uart_rx_unit: decode
    port map(clk=>clk, reset=>reset, baud_tick=>baud_tick, rx=>rx,
             byte=>rx_data_out, byte_tick=>rx_done_tick);
  fifo_rx_unit: fifo
    generic map(NADDRBITS=>FIFO_WIDTH, NDATABITS=>8)
    port map(clk=>clk, reset=>reset, rd=>rd_uart, r_data=>r_data,
             wr=>rx_done_tick, w_data=>rx_data_out,
             empty=>rd_empty, full=>open);

  fifo_tx_unit: fifo
    generic map(NADDRBITS=>FIFO_WIDTH, NDATABITS=>8)
    port map(clk=>clk, reset=>reset, rd=>tx_done_tick, r_data=>tx_fifo_out,
             wr=>wr_uart, w_data=>w_data, empty=>tx_empty, full=>wr_full);
  uart_tx_unit: encode
    port map(clk=>clk, reset=>reset, baud_tick=>baud_tick,
             byte=>tx_fifo_out, send_tick=>tx_fifo_not_empty,
             ready=>open, txd=>tx, done_tick=>tx_done_tick);

  tx_fifo_not_empty <= not tx_empty;
end arch;
