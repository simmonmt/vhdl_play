library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simmonmt;
use simmonmt.libbase.all;

package libvga is
  constant VGA_HRES: integer := 640;
  constant VGA_VRES: integer := 480;

  constant VGA_HPOS_WIDTH: integer := log2ceil(VGA_HRES-1);
  constant VGA_VPOS_WIDTH: integer := log2ceil(VGA_VRES-1);

  component vgagen is
    port(
      clk, reset: in std_logic;
      active: out std_logic;
      hpos: out unsigned(VGA_HPOS_WIDTH-1 downto 0);
      vpos: out unsigned(VGA_VPOS_WIDTH-1 downto 0);
      red, green, blue: in std_logic;

      vga_signal: out std_logic_vector(4 downto 0)
    );
  end component vgagen;
end libvga;
