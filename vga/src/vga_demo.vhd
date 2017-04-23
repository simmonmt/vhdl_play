library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libbase.all;
use simmonmt.libutil.all;

entity vga_demo is
  port(
    clk: in std_logic;
    vga: out std_logic_vector(4 downto 0);
    dbg: out std_logic_vector(7 downto 0)
  );
end vga_demo;

architecture arch of vga_demo is
  constant HRES: integer := 640;
  constant VRES: integer := 480;

  constant HPOS_WIDTH: integer := log2ceil(HRES-1);
  constant VPOS_WIDTH: integer := log2ceil(VRES-1);

  signal reset: std_logic;
  signal htick, hactive, hsync: std_logic;
  signal vtick, vactive, vsync: std_logic;
  signal hpos_reg, hpos_next: unsigned(HPOS_WIDTH-1 downto 0);
  signal vpos_reg, vpos_next: unsigned(VPOS_WIDTH-1 downto 0);
  signal active: std_logic;

  signal red, green, blue: std_logic;
begin
  startup_unit: startup
    port map(clk=>clk, reset=>reset);

  pulse_gen_unit: entity work.pulse_gen
    port map(clk=>clk, reset=>reset, htick=>htick, vtick=>vtick);

  hsync_gen_unit: entity work.sync_gen
    generic map(FRONT_PORCH=>16, SYNC_PULSE=>96, BACK_PORCH=>48,
                ACTIVE_REGION=>640)
    port map(clk=>clk, reset=>reset, tick=>htick, active=>hactive, sync=>hsync);

  vsync_gen_unit: entity work.sync_gen
    generic map(FRONT_PORCH=>10, SYNC_PULSE=>2, BACK_PORCH=>33,
                ACTIVE_REGION=>480)
    port map(clk=>clk, reset=>reset, tick=>vtick, active=>vactive, sync=>vsync);

  process(clk, reset)
  begin
    if reset = '1' then
      --count_reg <= (others=>'0');
      hpos_reg <= (others=>'0');
      vpos_reg <= (others=>'0');
    elsif rising_edge(clk) then
      --count_reg <= count_next;
      hpos_reg <= hpos_next;
      vpos_reg <= vpos_next;
    end if;
  end process;

  active <= '1' when hactive = '1' and vactive = '1' else '0';

  hpos_next <= (others=>'0') when hactive = '0' else
               hpos_reg when htick = '0' else
               (others=>'0') when hpos_reg = HRES-1 else
               hpos_reg + 1;

  vpos_next <= (others=>'0') when vactive = '0' else
               vpos_reg when vtick = '0' else
               (others=>'0') when vpos_reg = VRES-1 else
               vpos_reg + 1;

  red <= '0' when active = '0' else
         '1' when vpos_reg = 0 or vpos_reg = 1 or vpos_reg = 2 else
         '1' when vpos_reg = VRES-1 or vpos_reg = VRES-2 or
                  vpos_reg = VRES-3 else
         '1' when hpos_reg = 0 or hpos_reg = 1 or hpos_reg = 2 else
         '1' when hpos_reg = HRES-1 or hpos_reg = HRES-2 or
                  hpos_reg = HRES-3 else
         '0';
  green <= '0' when active = '0' else
         '1' when vpos_reg = 3 or vpos_reg = 4 or vpos_reg = 5 else
         '1' when vpos_reg = VRES-4 or vpos_reg = VRES-5 or
                  vpos_reg = VRES-6 else
         '1' when hpos_reg = 3 or hpos_reg = 4 or hpos_reg = 5 else
         '1' when hpos_reg = HRES-4 or hpos_reg = HRES-5 or
                  hpos_reg = HRES-6 else
         '0';
  blue <= '0' when active = '0' else
         '1' when vpos_reg = 6 or vpos_reg = 7 or vpos_reg = 8 else
         '1' when vpos_reg = VRES-7 or vpos_reg = VRES-8 or
                  vpos_reg = VRES-9 else
         '1' when hpos_reg = 6 or hpos_reg = 7 or hpos_reg = 8 else
         '1' when hpos_reg = HRES-7 or hpos_reg = HRES-8 or
                  hpos_reg = HRES-9 else
         '0';

  dbg(7 downto 2) <= std_logic_vector(vpos_reg(5 downto 0));
  dbg(1) <= vtick;
  dbg(0) <= active;

  vga(0) <= vsync;
  vga(1) <= hsync;
  vga(2) <= red;
  vga(3) <= green;
  vga(4) <= blue;
end arch;
