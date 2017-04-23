library ieee;
use ieee.std_logic_1164.all;

entity startup is
  port(
    clk: in std_logic;
    reset: out std_logic
  );
end startup;

architecture arch of startup is
  signal cnt: std_logic_vector(1 downto 0) := "00";
  signal cnt_next: std_logic_vector(1 downto 0);
begin
  reset <= not (cnt(0) and cnt(1));

  cnt_next <= "01" when cnt = "00" else
              "10" when cnt = "01" else
              "11";

  process(clk)
  begin
    if clk'event and clk = '1' then
      if cnt /= "11" then
        cnt <= cnt_next;
      end if;
    end if;
  end process;
end arch;
