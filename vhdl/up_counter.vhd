--------------------------------------------------------------------------------
-- 16 bit counter
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity up_counter is
    Port (
        clk     : in std_logic;
        reset   : in std_logic;
        value   : out std_logic_vector(15 downto 0)
    );
end up_counter;

architecture Behavioral of up_counter is
    signal sig_val: std_logic_vector(15 downto 0);
begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset='1') then
                sig_val <= x"0000";
            else
                sig_val <= sig_val + x"0001";
            end if;
         end if;
    end process;

    value <= sig_val;

end Behavioral;
