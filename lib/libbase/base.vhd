package body libbase is
  function log2ceil(x: natural) return integer is
    variable i: natural;
  begin
    i := 0;
    while (2**i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end log2ceil;
end libbase;
