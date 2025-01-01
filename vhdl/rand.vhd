
process(clk)

    -- maximal length 32-bit xnor LFSR based on xilinx app note XAPP210
    function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
    end function;

begin
    if rising_edge(clk) then
        if rst='1' then
            pseudo_rand <= (others => '0');
        else
            pseudo_rand <= lfsr32(psuedo_rand);
        end if;
    end if;
end process;
