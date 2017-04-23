library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libbase.all;
use simmonmt.libutil.all;
use simmonmt.libvga.all;

entity vga_demo is
  port(
    clk: in std_logic;
    vga: out std_logic_vector(4 downto 0);
    dbg: out std_logic_vector(7 downto 0)
  );
end vga_demo;

architecture arch of vga_demo is
  signal reset: std_logic;
  signal vga_active: std_logic;
  signal vga_hpos: unsigned(VGA_HPOS_WIDTH-1 downto 0);
  signal vga_vpos: unsigned(VGA_VPOS_WIDTH-1 downto 0);

  signal red, green, blue: std_logic;
begin
  startup_unit: startup
    port map(clk=>clk, reset=>reset);

  vga_unit: vgagen
    port map(clk=>clk, reset=>reset,
             active=>vga_active, hpos=>vga_hpos, vpos=>vga_vpos,
             red=>red, green=>green, blue=>blue,
             vga_signal=>vga);

  --process(clk, reset)
  --begin
  --  if reset = '1' then
  --  elsif rising_edge(clk) then
  --  end if;
  --end process;

  red <= '0' when vga_active = '0' else
         '1' when vga_vpos = 0 or vga_vpos = 1 or vga_vpos = 2 else
         '1' when vga_vpos = VGA_VRES-1 or vga_vpos = VGA_VRES-2 or
                  vga_vpos = VGA_VRES-3 else
         '1' when vga_hpos = 0 or vga_hpos = 1 or vga_hpos = 2 else
         '1' when vga_hpos = VGA_HRES-1 or vga_hpos = VGA_HRES-2 or
                  vga_hpos = VGA_HRES-3 else
         '0';
  green <= '0' when vga_active = '0' else
         '1' when vga_vpos = 3 or vga_vpos = 4 or vga_vpos = 5 else
         '1' when vga_vpos = VGA_VRES-4 or vga_vpos = VGA_VRES-5 or
                  vga_vpos = VGA_VRES-6 else
         '1' when vga_hpos = 3 or vga_hpos = 4 or vga_hpos = 5 else
         '1' when vga_hpos = VGA_HRES-4 or vga_hpos = VGA_HRES-5 or
                  vga_hpos = VGA_HRES-6 else
         '0';
  blue <= '0' when vga_active = '0' else
         '1' when vga_vpos = 6 or vga_vpos = 7 or vga_vpos = 8 else
         '1' when vga_vpos = VGA_VRES-7 or vga_vpos = VGA_VRES-8 or
                  vga_vpos = VGA_VRES-9 else
         '1' when vga_hpos = 6 or vga_hpos = 7 or vga_hpos = 8 else
         '1' when vga_hpos = VGA_HRES-7 or vga_hpos = VGA_HRES-8 or
                  vga_hpos = VGA_HRES-9 else
         '0';

  dbg <= (others=>'0');

end arch;
