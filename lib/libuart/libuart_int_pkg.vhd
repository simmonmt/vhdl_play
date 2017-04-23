library ieee;
use ieee.std_logic_1164.all;

package libuart_int is
  component encode is
    port(
      clk, reset: in std_logic;
      baud_tick: in std_logic;
      byte: in std_logic_vector(7 downto 0);
      send_tick: in std_logic;
      ready: out std_logic;
      txd: out std_logic;
      done_tick: out std_logic
      );
  end component encode;

  component decode is
    port(
      clk, reset: in std_logic;
      baud_tick, rx: in std_logic;
      byte: out std_logic_vector(7 downto 0);
      byte_tick: out std_logic
      );
  end component decode;
end libuart_int;
