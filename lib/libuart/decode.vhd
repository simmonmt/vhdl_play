library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libutil.all;

entity decode is
  port(
    clk, reset: in std_logic;
    baud_tick, rx: in std_logic;
    byte: out std_logic_vector(7 downto 0);
    byte_tick: out std_logic
  );
end decode;

architecture arch of decode is
  signal count_reg, count_next: unsigned(4 downto 0);
  signal count_reset: std_logic;

  type state_type is (init, low, bitwait, wantstop);
  signal state_reg, state_next: state_type;

  signal byte_tick_reg, byte_tick_next: std_logic;
  signal nbits_reg, nbits_next: unsigned(2 downto 0);

  signal byte_reg, byte_next: std_logic_vector(7 downto 0);
  signal bit_sample: std_logic;

  signal htol_tick: std_logic;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      count_reg <= (others=>'0');
      state_reg <= init;
      nbits_reg <= (others=>'0');
      byte_reg <= (others=>'0');
      byte_tick_reg <= '0';
    elsif rising_edge(clk) then
      count_reg <= count_next;
      state_reg <= state_next;
      nbits_reg <= nbits_next;
      byte_reg <= byte_next;
      byte_tick_reg <= byte_tick_next;
    end if;
  end process;

  falling_edge_unit: falling_edge_detector
    port map(clk=>clk, reset=>reset, level=>rx, tick=>htol_tick);

  count_next <= (others=>'0') when count_reset = '1' else
                count_reg + 1 when baud_tick = '1' else
                count_reg;

  -- RS232 sends bits LSB first, so shift them in from the left
  byte_next <= rx & byte_reg(7 downto 1) when bit_sample = '1' else
               byte_reg;

  process(state_reg, count_reg, rx, nbits_reg, htol_tick)
  begin
    state_next <= state_reg;
    count_reset <= '0';
    bit_sample <= '0';
    nbits_next <= nbits_reg;
    byte_tick_next <= '0';

    case state_reg is
      when init =>
        if htol_tick = '1' then
          count_reset <= '1';
          state_next <= low;
        end if;

      when low =>
        -- read the start bit
        if count_reg = 8 then
          if rx = '0' then
            state_next <= bitwait;
            count_reset <= '1';
          else
            state_next <= init;
          end if;
        end if;

      when bitwait =>
        -- read the data bits
        if count_reg(4) = '1' then
          bit_sample <= '1';
          nbits_next <= nbits_reg + 1;
          count_reset <= '1';

          if nbits_reg = 7 then
            state_next <= wantstop;
          end if;
        end if;

      when wantstop =>
        -- read the stop bit
        if count_reg(4) = '1' then
          if rx = '1' then
            byte_tick_next <= '1';
          end if;
          state_next <= init;
        end if;
    end case;
  end process;

  byte <= byte_reg;
  byte_tick <= byte_tick_reg;
end arch;
