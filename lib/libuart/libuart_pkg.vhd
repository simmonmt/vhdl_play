library ieee;
use ieee.std_logic_1164.all;

package libuart is
  component uart is
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
  end component uart;
end libuart;
