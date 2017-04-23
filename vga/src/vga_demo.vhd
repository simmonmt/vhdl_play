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
  constant TBORDER: integer := 2;
  constant BBORDER: integer := VGA_VRES-3;
  constant LBORDER: integer := 2;
  constant RBORDER: integer := VGA_HRES-3;

  signal reset: std_logic;
  signal vga_active: std_logic;
  signal vga_hpos: unsigned(VGA_HPOS_WIDTH-1 downto 0);
  signal vga_vpos: unsigned(VGA_VPOS_WIDTH-1 downto 0);
  signal boxx_reg, boxx_next: unsigned(VGA_HPOS_WIDTH-1 downto 0);
  signal boxy_reg, boxy_next: unsigned(VGA_VPOS_WIDTH-1 downto 0);
  signal dirx_reg, dirx_next, diry_reg, diry_next: std_logic;
  signal dir_bits: std_logic_vector(1 downto 0);
  signal counter_tick: std_logic;
  signal inbox: std_logic;
  signal color: std_logic_vector(2 downto 0);
  signal red, green, blue: std_logic;
begin
  startup_unit: startup
    port map(clk=>clk, reset=>reset);

  counter_unit: counter
    generic map(WIDTH=>18)
    port map(clk=>clk, reset=>reset, tick=>counter_tick);

  vga_unit: vgagen
    port map(clk=>clk, reset=>reset,
             active=>vga_active, hpos=>vga_hpos, vpos=>vga_vpos,
             red=>red, green=>green, blue=>blue,
             vga_signal=>vga);

  process(clk, reset)
  begin
    if reset = '1' then
      boxx_reg <= to_unsigned(2, VGA_HPOS_WIDTH);
      boxy_reg <= to_unsigned(2, VGA_VPOS_WIDTH);
      dirx_reg <= '0';
      diry_reg <= '0';
    elsif rising_edge(clk) then
      boxx_reg <= boxx_next;
      boxy_reg <= boxy_next;
      dirx_reg <= dirx_next;
      diry_reg <= diry_next;
    end if;
  end process;

  dirx_next <= '1' when boxx_reg = LBORDER else
               '0' when boxx_reg = RBORDER else
               dirx_reg;
  diry_next <= '1' when boxy_reg = TBORDER else
               '0' when boxy_reg = BBORDER else
               diry_reg;

  dir_bits <= dirx_reg & diry_reg;
  color <= "100" when dir_bits = "00" else
           "010" when dir_bits = "01" else
           "101" when dir_bits = "10" else
           "110";

  boxx_next <= boxx_reg when counter_tick = '0' else
               boxx_reg + 1 when dirx_reg = '1' else
               boxx_reg - 1;
  boxy_next <= boxy_reg when counter_tick = '0' else
               boxy_reg + 1 when diry_reg = '1' else
               boxy_reg - 1;

  inbox <= '1' when vga_hpos >= boxx_reg-2 and
                    vga_hpos <= boxx_reg+2 and
                    vga_vpos >= boxy_reg-2 and
                    vga_vpos <= boxy_reg+2 else
           '0';

  red <= '1' when color(2) = '1' and vga_active = '1' and inbox = '1' else '0';
  green <= '1' when color(1) = '1' and vga_active = '1' and inbox = '1' else '0';
  blue <= '1' when color(0) = '1' and vga_active = '1' and inbox = '1' else '0';

  --red <= '0' when vga_active = '0' else
  --       '1' when vga_vpos = 0 or vga_vpos = 1 or vga_vpos = 2 else
  --       '1' when vga_vpos = VGA_VRES-1 or vga_vpos = VGA_VRES-2 or
  --                vga_vpos = VGA_VRES-3 else
  --       '1' when vga_hpos = 0 or vga_hpos = 1 or vga_hpos = 2 else
  --       '1' when vga_hpos = VGA_HRES-1 or vga_hpos = VGA_HRES-2 or
  --                vga_hpos = VGA_HRES-3 else
  --       '0';
  --green <= '0' when vga_active = '0' else
  --       '1' when vga_vpos = 3 or vga_vpos = 4 or vga_vpos = 5 else
  --       '1' when vga_vpos = VGA_VRES-4 or vga_vpos = VGA_VRES-5 or
  --                vga_vpos = VGA_VRES-6 else
  --       '1' when vga_hpos = 3 or vga_hpos = 4 or vga_hpos = 5 else
  --       '1' when vga_hpos = VGA_HRES-4 or vga_hpos = VGA_HRES-5 or
  --                vga_hpos = VGA_HRES-6 else
  --       '0';
  --blue <= '0' when vga_active = '0' else
  --       '1' when vga_vpos = 6 or vga_vpos = 7 or vga_vpos = 8 else
  --       '1' when vga_vpos = VGA_VRES-7 or vga_vpos = VGA_VRES-8 or
  --                vga_vpos = VGA_VRES-9 else
  --       '1' when vga_hpos = 6 or vga_hpos = 7 or vga_hpos = 8 else
  --       '1' when vga_hpos = VGA_HRES-7 or vga_hpos = VGA_HRES-8 or
  --                vga_hpos = VGA_HRES-9 else
  --       '0';

  dbg <= (others=>'0');

end arch;
