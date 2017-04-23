library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libvga.all;

entity vgagen is
  port(
    clk, reset: in std_logic;
    active: out std_logic;
    hpos: out unsigned(VGA_HPOS_WIDTH-1 downto 0);
    vpos: out unsigned(VGA_VPOS_WIDTH-1 downto 0);
    red, green, blue: in std_logic;

    vga_signal: out std_logic_vector(4 downto 0)
  );
end vgagen;

architecture arch of vgagen is
  signal htick, hactive, hsync: std_logic;
  signal vtick, vactive, vsync: std_logic;
  signal hpos_reg, hpos_next: unsigned(VGA_HPOS_WIDTH-1 downto 0);
  signal vpos_reg, vpos_next: unsigned(VGA_VPOS_WIDTH-1 downto 0);
begin
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
      hpos_reg <= (others=>'0');
      vpos_reg <= (others=>'0');
    elsif rising_edge(clk) then
      hpos_reg <= hpos_next;
      vpos_reg <= vpos_next;
    end if;
  end process;

  active <= '1' when hactive = '1' and vactive = '1' else '0';
  hpos <= hpos_reg;
  vpos <= vpos_reg;

  hpos_next <= (others=>'0') when hactive = '0' else
               hpos_reg when htick = '0' else
               (others=>'0') when hpos_reg = VGA_HRES-1 else
               hpos_reg + 1;

  vpos_next <= (others=>'0') when vactive = '0' else
               vpos_reg when vtick = '0' else
               (others=>'0') when vpos_reg = VGA_VRES-1 else
               vpos_reg + 1;

  vga_signal(0) <= vsync;
  vga_signal(1) <= hsync;
  vga_signal(2) <= red;
  vga_signal(3) <= green;
  vga_signal(4) <= blue;
end arch;
