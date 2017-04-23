library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encode is
  port(
    clk, reset: in std_logic;
    baud_tick: in std_logic;
    byte: in std_logic_vector(7 downto 0);
    send_tick: in std_logic;
    ready: out std_logic;
    txd: out std_logic;
    done_tick: out std_logic
  );
end encode;

architecture arch of encode is
  -- The baud generator oversamples 16x, but we only need 1x, so we have to
  -- divide it back down.
  signal counter_reg, counter_next: unsigned(3 downto 0);
  signal counter_reset: std_logic;

  type state_type is (init, send, sendwait);
  signal state_reg, state_next: state_type;

  signal count_reset: std_logic;
  signal frame_reg, frame_next: std_logic_vector(9 downto 0);
  signal tosend_reg, tosend_next: unsigned(3 downto 0);
  signal txd_reg, txd_next: std_logic;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      state_reg <= init;
      tosend_reg <= (others=>'0');
      counter_reg <= (others=>'0');
      txd_reg <= '1';
      frame_reg <= (others=>'0');
    elsif rising_edge(clk) then
      state_reg <= state_next;
      tosend_reg <= tosend_next;
      counter_reg <= counter_next;
      txd_reg <= txd_next;
      frame_reg <= frame_next;
    end if;
  end process;

  counter_next <= (others=>'0') when counter_reset = '1' else
                  counter_reg + 1 when baud_tick = '1' else
                  counter_reg;

  ready <= '1' when state_reg = init else '0';

  process(state_reg, byte, frame_reg, tosend_reg, txd_reg, send_tick,
          counter_reg, baud_tick)
  begin
    counter_reset <= '0';
    frame_next <= frame_reg;
    state_next <= state_reg;
    tosend_next <= tosend_reg;
    txd_next <= txd_reg;
    done_tick <= '0';

    case state_reg is
      when init =>
        if send_tick = '1' then
          frame_next <= '1' & byte & '0';  -- stop, bits*8, start
          tosend_next <= to_unsigned(10, 4);
          state_next <= send;
          counter_reset <= '1';
        end if;

      when send =>
        if baud_tick = '1' then
          txd_next <= frame_reg(0);
          state_next <= sendwait;
        end if;

      when sendwait =>
        if counter_reg = 15 and baud_tick = '1' then
          if tosend_reg = "0001" then
            done_tick <= '1';
            state_next <= init;
          else
            tosend_next <= tosend_reg - 1;
            frame_next <= '0' & frame_reg(9 downto 1);
            state_next <= send;
          end if;
        end if;
    end case;
  end process;

  txd <= txd_reg;
end arch;
