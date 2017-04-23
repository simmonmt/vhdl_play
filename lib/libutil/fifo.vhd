library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
  generic(
    NDATABITS: natural := 8;  -- number of bits
    NADDRBITS: natural := 4   -- number of address bits
  );
  port(
    clk, reset: in std_logic;
    rd, wr: in std_logic;
    r_data: out std_logic_vector(NDATABITS-1 downto 0);
    w_data: in std_logic_vector(NDATABITS-1 downto 0);
    empty, full: out std_logic
  );
end fifo;

architecture arch of fifo is
  type reg_file_type is array (2**NADDRBITS-1 downto 0) of
    std_logic_vector(NDATABITS-1 downto 0);
  signal array_reg: reg_file_type;

  signal r_ptr_reg, r_ptr_next, r_ptr_succ:
    std_logic_vector(NADDRBITS-1 downto 0);
  signal w_ptr_reg, w_ptr_next, w_ptr_succ:
    std_logic_vector(NADDRBITS-1 downto 0);
  signal full_reg, empty_reg, full_next, empty_next: std_logic;
  signal rw_op: std_logic_vector(1 downto 0);
  signal wr_en: std_logic;
begin
  --
  -- register file
  --
  process(clk, reset)
  begin
    if reset = '1' then
      array_reg <= (others=>(others=>'0'));
    elsif clk'event and clk = '1' then
      if wr_en = '1' then
        array_reg(to_integer(unsigned(w_ptr_reg))) <= w_data;
      end if;
    end if;
  end process;

  r_data <= array_reg(to_integer(unsigned(r_ptr_reg)));  -- read port
  wr_en <= wr and (not full_reg);  -- write enabled iff FIFO is not full

  --
  -- fifo control logic
  --

  -- register for read and write pointers
  process(clk, reset)
  begin
    if reset = '1' then
      r_ptr_reg <= (others=>'0');
      w_ptr_reg <= (others=>'0');
      full_reg <= '0';
      empty_reg <= '1';
    elsif clk'event and clk = '1' then
      r_ptr_reg <= r_ptr_next;
      w_ptr_reg <= w_ptr_next;
      full_reg <= full_next;
      empty_reg <= empty_next;
    end if;
  end process;

  -- successive pointer values
  r_ptr_succ <= std_logic_vector(unsigned(r_ptr_reg) + 1);
  w_ptr_succ <= std_logic_vector(unsigned(w_ptr_reg) + 1);

  -- next-state logic for read and write pointers
  rw_op <= rd & wr;
  process(r_ptr_reg, r_ptr_succ, w_ptr_reg, w_ptr_succ, rw_op,
          empty_reg, full_reg)
  begin
    r_ptr_next <= r_ptr_reg;
    w_ptr_next <= w_ptr_reg;
    full_next <= full_reg;
    empty_next <= empty_reg;

    case rw_op is
      when "00" => -- no op
      when "10" => -- read
        if empty_reg /= '1' then -- not empty
          r_ptr_next <= r_ptr_succ;
          full_next <= '0';
          if r_ptr_succ = w_ptr_reg then
            empty_next <= '1';
          end if;
        end if;
      when "01" => -- write
        if full_reg /= '1' then -- not full
          w_ptr_next <= w_ptr_succ;
          empty_next <= '0';
          if w_ptr_succ = r_ptr_reg then
            full_next <= '1';
          end if;
        end if;
      when others => -- read and write
        r_ptr_next <= r_ptr_succ;
        w_ptr_next <= w_ptr_succ;
    end case;
  end process;

  -- output
  full <= full_reg;
  empty <= empty_reg;
end arch;
