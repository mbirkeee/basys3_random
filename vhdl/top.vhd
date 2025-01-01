----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port(
        clock_100Mhz    : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
        Anode_Activate  : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
        LED_out         : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display

        btnC        : in STD_LOGIC;
        btnU        : in STD_LOGIC;
        btnD        : in STD_LOGIC;
        btnL        : in STD_LOGIC;
        btnR        : in STD_LOGIC;

        led         : out STD_LOGIC_VECTOR (15 downto 0)
    );
end top;

ARCHITECTURE Behavioral of top is

    signal displayed_number     : STD_LOGIC_VECTOR (15 downto 0);
    signal displayed_number2    : std_logic_vector (15 downto 0);
    signal random_number        : std_logic_vector (15 downto 0);
    signal buttons              : STD_LOGIC_VECTOR (4 downto 0);
    signal LED_BCD              : STD_LOGIC_VECTOR (3 downto 0);
    signal sr_rand              : std_logic_vector (31 downto 0);
    
    signal trigger_counter      : STD_LOGIC_VECTOR (31 downto 0);
    signal trigger              : STD_LOGIC;    
    signal ready_counter        : STD_LOGIC_VECTOR (3 downto 0);

    -- counter to cycle through the four numeric displays
    signal select_counter       : STD_LOGIC_VECTOR(1 downto 0);
    signal segment_mux          : STD_LOGIC_VECTOR(15 downto 0);
    signal selected             : STD_LOGIC_VECTOR(1 downto 0);
    
    signal high                 : STD_LOGIC;
    signal btnC_debounced       : STD_LOGIC;
    signal btnL_debounced       : STD_LOGIC;
    signal btnR_debounced       : STD_LOGIC;
    signal btnU_debounced       : STD_LOGIC;
    signal btnD_debounced       : STD_LOGIC;
    signal btn_pressed          : STD_LOGIC;

    ---------------------------------------------------------------------------

    function psuedo_random_shift_register(
        x : std_logic_vector(31 downto 0)
    ) return std_logic_vector is
    begin
        return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
    end function;
    ----------------------------------------------------------------------------
    component debounce
        Port(
            clk     : IN  STD_LOGIC;  --input clock
            reset_n : IN  STD_LOGIC;  --asynchronous active low reset
            button  : IN  STD_LOGIC;  --input signal to be debounced
            result  : OUT STD_LOGIC
        );
    end component;
    ----------------------------------------------------------------------------
    begin

    ----------------------------------------------------------------------------
    -- Debounce all the buttons
    ----------------------------------------------------------------------------
    high <= '1';

    c0: debounce
        port map(clock_100Mhz, high, btnC, btnC_debounced);

    c1: debounce
        port map(clock_100Mhz, high, btnL, btnL_debounced);

    c2: debounce
        port map(clock_100Mhz, high, btnR, btnR_debounced);

    c3: debounce
        port map(clock_100Mhz, high, btnU, btnU_debounced);

    c4: debounce
        port map(clock_100Mhz, high, btnD, btnD_debounced);

    btn_pressed <= (btnL_debounced or
                    btnR_debounced or
                    btnU_debounced or
                    btnD_debounced or
                    btnC_debounced);

    -- buttons(0) <= btnL_debounced;
    -- buttons(1) <= btnR_debounced;
    -- buttons(2) <= btnU_debounced;
    -- buttons(3) <= btnD_debounced;
    -- buttons(4) <= btnC_debounced;
    --
    -- led(4 downto 0) <= buttons;

--    process(btnL_debounced, btnR_debounced, btnU_debounced, btnD_debounced, btnC_debounced)
--    begin
--        btn_pressed <= (btnL_debounced or btnR_debounced or btnU_debounced );
--
--    end process;

    process(clock_100Mhz) begin
        if(rising_edge(clock_100Mhz)) then
            trigger_counter <= trigger_counter + 1;
--            if trigger_counter = x"2faf08" then
            -- if trigger_counter = x"632ea00" then
            if trigger_counter = x"632ea0" then
            -- if trigger_counter = x"632ea00" then
                trigger <= '1';
                trigger_counter <= x"00000000";
            else    
                trigger <= '0';
                
           end if;
        end if;
        
    end process;
          
           
    -------------------------------------------------------------
    -- Since all that is being done here is a random number
    -- generation, might as well go as fast as component debounce
    -------------------------------------------------------------
    process(clock_100Mhz)
    begin
        if rising_edge(clock_100Mhz) then

            sr_rand <= psuedo_random_shift_register(x => sr_rand);
            random_number(15 downto 1) <= random_number(14 downto 0) ;
            random_number(0) <= sr_rand(0);
        end if;
    end process;

    process(trigger)
    begin
        if rising_edge(trigger) then
            if btn_pressed = '0' then
                displayed_number <= random_number;
            end if;
        end if;
    end process;
    
    --led(3 downto 0) <= ready_counter;
    --led(15 downto 4) <= random_number(11 downto 0);
    led <= displayed_number;

    -- This causes the displayed number to be output on the seven segment display
    ----------------------------------------------------------------------------
    process(LED_BCD)
    begin
        case LED_BCD is
            when "0000" => LED_out <= "0000001"; -- "0"
            when "0001" => LED_out <= "1001111"; -- "1"
            when "0010" => LED_out <= "0010010"; -- "2"
            when "0011" => LED_out <= "0000110"; -- "3"
            when "0100" => LED_out <= "1001100"; -- "4"
            when "0101" => LED_out <= "0100100"; -- "5"
            when "0110" => LED_out <= "0100000"; -- "6"
            when "0111" => LED_out <= "0001111"; -- "7"
            when "1000" => LED_out <= "0000000"; -- "8"
            when "1001" => LED_out <= "0000100"; -- "9"
            when "1010" => LED_out <= "0001000"; -- A
            when "1011" => LED_out <= "1100000"; -- b
            when "1100" => LED_out <= "0110001"; -- C
            when "1101" => LED_out <= "1000010"; -- d
            when "1110" => LED_out <= "0110000"; -- E
            when "1111" => LED_out <= "0111000"; -- F
        end case;
    end process;

    process(clock_100Mhz) begin
        if(rising_edge(clock_100Mhz)) then
            segment_mux <= segment_mux + 1;
        end if;
    end process;

    selected <= segment_mux(13 downto 12);
    ----------------------------------------------------------------------------
    -- 4-to-1 MUX to generate anode activating signals for 4 LEDs
    ----------------------------------------------------------------------------
    process(selected)
    begin
        case selected is
            when "00" =>
                Anode_Activate <= "0111";
                -- activate LED1 and Deactivate LED2, LED3, LED4
                LED_BCD <= displayed_number(15 downto 12);
                --LED_BCD <= displayed_number(3 downto 0);

                -- the first hex digit of the 16-bit number
            when "01" =>
                Anode_Activate <= "1011";
                -- activate LED2 and Deactivate LED1, LED3, LED4
                LED_BCD <= displayed_number(11 downto 8);
--                LED_BCD <= displayed_number(3 downto 0);
                -- the second hex digit of the 16-bit number
            when "10" =>
                Anode_Activate <= "1101";
                -- activate LED3 and Deactivate LED2, LED1, LED4
                LED_BCD <= displayed_number(7 downto 4);
--                LED_BCD <= displayed_number(3 downto 0);
                -- the third hex digit of the 16-bit number
            when "11" =>
                Anode_Activate <= "1110";
                -- activate LED4 and Deactivate LED2, LED3, LED1
                LED_BCD <= displayed_number(3 downto 0);
                -- the fourth hex digit of the 16-bit number
        end case;
    end process;
---------------------------------------------------------------
end Behavioral;
