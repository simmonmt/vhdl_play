library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libbase.all;

entity sync_gen is
  generic(
    -- Default values are for HSYNC for 640x480, in ticks
    FRONT_PORCH: integer := 16;
    SYNC_PULSE: integer := 96;
    BACK_PORCH: integer := 48;
    ACTIVE_REGION: integer := 640
  );
  port(
    clk, reset: in std_logic;
    tick: in std_logic;
    active: out std_logic;
    sync: out std_logic
    );
end sync_gen;

architecture arch of sync_gen is
  constant FRONT_START: integer := 0;
  constant SYNC_START: integer := FRONT_START + FRONT_PORCH;
  constant BACK_START: integer := SYNC_START + SYNC_PULSE;
  constant ACTIVE_START: integer := BACK_START + BACK_PORCH;
  constant WHOLE_LEN: integer := ACTIVE_START + ACTIVE_REGION;

  type state_type is (st_front, st_sync, st_back, st_active);
  signal state_reg, state_next: state_type;

  signal count_reg, count_next: unsigned(log2ceil(WHOLE_LEN)-1 downto 0);
  signal sync_reg, sync_next: std_logic;
  signal active_reg, active_next: std_logic;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      state_reg <= st_front;
      count_reg <= (others=>'0');
      sync_reg <= '1';
      active_reg <= '0';
    elsif rising_edge(clk) then
      state_reg <= state_next;
      count_reg <= count_next;
      sync_reg <= sync_next;
      active_reg <= active_next;
    end if;
  end process;

  count_next <= (others=>'0') when count_reg = WHOLE_LEN-1 and tick = '1' else
                count_reg + 1 when tick = '1' else
                count_reg;

  sync <= sync_reg;
  active <= active_reg;

  process(state_reg, count_reg)
  begin
    state_next <= state_reg;
    sync_next <= '1';
    active_next <= '0';

    case state_reg is
      when st_front =>
        if count_reg = SYNC_START-1 then
          state_next <= st_sync;
        end if;
      when st_sync =>
        sync_next <= '0';
        if count_reg = BACK_START-1 then
          state_next <= st_back;
        end if;
      when st_back =>
        if count_reg = ACTIVE_START-1 then
          state_next <= st_active;
        end if;
      when st_active =>
        active_next <= '1';
        if count_reg = WHOLE_LEN-1 then
          state_next <= st_front;
        end if;
    end case;
  end process;
end arch;
