library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity declaration for the Mastermind game
entity mastermind_game is
    Port (
        clk_fast        : in  STD_LOGIC;                     -- Clock input
        btn_add    : in  STD_LOGIC;                     -- Add button to set answer
        btn_inc    : in  STD_LOGIC;                     -- Increment selected LED color
        btn_next   : in  STD_LOGIC;                     -- Move to next LED
        btn_submit : in  STD_LOGIC;                     -- Submit current guess
        btn_reset  : in  STD_LOGIC;                     -- Reset the game

        rgb_leds   : out STD_LOGIC_VECTOR(11 downto 0); -- Output to RGB LEDs (4 LEDs x 3 colors)
        green_leds : out STD_LOGIC_VECTOR(3 downto 0);  -- Correct color and position indicators
        blue_leds  : out STD_LOGIC_VECTOR(3 downto 0);  -- Correct color, wrong position indicators
        buzzer     : out STD_LOGIC                      -- Buzzer output
    );
end mastermind_game;

architecture Behavioral of mastermind_game is
    -- Game state using explicit 2-bit encoding to save resources
    signal state    : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- 00=SET_ANSWER, 01=PLAYING, 10=WIN, 11=RESET
    
    -- Game signals
    signal answer   : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal guess    : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal rgb_out  : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal green_out: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal blue_out : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    -- Minimal signals for game logic
    signal color    : STD_LOGIC_VECTOR(2 downto 0) := "001"; -- Current color (cycles 1-6)
    signal index    : STD_LOGIC_VECTOR(1 downto 0) := "00";  -- Current position (0-3)
    signal setup_done : STD_LOGIC := '0';                    -- Flag for setup completion
    signal blink    : STD_LOGIC := '0';                      -- For LED blinking
    signal clk_div  : STD_LOGIC_VECTOR(9 downto 0) := (others => '0'); -- Clock divider
    
    -- Button edge detection
    signal btn_add_prev, btn_inc_prev, btn_next_prev, btn_submit_prev, btn_reset_prev : STD_LOGIC := '0';
    
begin
    -- Direct output assignments
    rgb_leds <= rgb_out;
    green_leds <= green_out;
    blue_leds <= blue_out;
    
    -- Clock divider for blinking effects
    process(clk_fast)
    begin
        if rising_edge(clk_fast) then
            clk_div <= clk_div + 1;
            -- Make blinking happen faster for better visual effect
            if clk_div(9) = '1' then
                blink <= not blink;
            end if;
        end if;
    end process;
    
    -- Main game logic
    process(clk_fast)
        variable correct_pos : integer range 0 to 4 := 0;
        variable temp_color : STD_LOGIC_VECTOR(2 downto 0);
        variable win_flag : STD_LOGIC := '0';
    begin
        if rising_edge(clk_fast) then
            -- Cycle the color counter (1-6) continuously
            if color = "110" then
                color <= "001";
            else
                color <= color + 1;
            end if;
            
            -- Button edge detection
            btn_add_prev <= btn_add;
            btn_inc_prev <= btn_inc;
            btn_next_prev <= btn_next;
            btn_submit_prev <= btn_submit;
            btn_reset_prev <= btn_reset;
            
            -- Handle reset button from any state
            if btn_reset = '1' and btn_reset_prev = '0' then
                state <= "11"; -- RESET state
                rgb_out <= (others => '0');
                green_out <= (others => '0');
                blue_out <= (others => '0');
                buzzer <= '0';
            end if;
            
            -- Main state machine
            case state is
                when "00" => -- SET_ANSWER state
                    buzzer <= '0';
                    
                    -- Visual indicator for setup state
                    rgb_out <= "010010010010"; -- All LEDs green
                    
                    -- Button to set next color in answer
                    if btn_add = '1' and btn_add_prev = '0' then
                        -- Set the color at current position
                        case index is
                            when "00" => 
                                answer(11 downto 9) <= color;
                                index <= "01";
                            when "01" => 
                                answer(8 downto 6) <= color;
                                index <= "10";
                            when "10" => 
                                answer(5 downto 3) <= color;
                                index <= "11";
                            when "11" => 
                                answer(2 downto 0) <= color;
                                setup_done <= '1';
                            when others => null;
                        end case;
                    end if;
                    
                    -- Move to PLAYING state when setup is complete
                    if setup_done = '1' then
                        state <= "01"; -- PLAYING state
                        rgb_out <= (others => '0');
                        index <= "00"; -- Reset index for playing state
                        setup_done <= '0';
                    end if;
                
                when "01" => -- PLAYING state
                    -- Show current guess
                    rgb_out <= guess;
                    buzzer <= '0';
                    
                    -- Button to increment color
                    if btn_inc = '1' and btn_inc_prev = '0' then
                        case index is
                            when "00" => 
                                temp_color := guess(11 downto 9);
                                if temp_color = "110" then
                                    guess(11 downto 9) <= "001";
                                else
                                    guess(11 downto 9) <= temp_color + 1;
                                end if;
                            when "01" => 
                                temp_color := guess(8 downto 6);
                                if temp_color = "110" then
                                    guess(8 downto 6) <= "001";
                                else
                                    guess(8 downto 6) <= temp_color + 1;
                                end if;
                            when "10" => 
                                temp_color := guess(5 downto 3);
                                if temp_color = "110" then
                                    guess(5 downto 3) <= "001";
                                else
                                    guess(5 downto 3) <= temp_color + 1;
                                end if;
                            when "11" => 
                                temp_color := guess(2 downto 0);
                                if temp_color = "110" then
                                    guess(2 downto 0) <= "001";
                                else
                                    guess(2 downto 0) <= temp_color + 1;
                                end if;
                            when others => null;
                        end case;
                    end if;
                    
                    -- Button to move to next position
                    if btn_next = '1' and btn_next_prev = '0' then
                        if index = "11" then
                            index <= "00";
                        else
                            index <= index + 1;
                        end if;
                    end if;
                    
                    -- Button to submit guess
                    if btn_submit = '1' and btn_submit_prev = '0' then
                        -- Reset feedback indicators
                        green_out <= (others => '0');
                        blue_out <= (others => '0');
                        correct_pos := 0;
                        win_flag := '1'; -- Assume win until proven otherwise
                        
                        -- Check exact matches (position and color)
                        if guess(11 downto 9) = answer(11 downto 9) then
                            green_out(0) <= '1';
                            correct_pos := correct_pos + 1;
                        else
                            win_flag := '0';
                        end if;
                        
                        if guess(8 downto 6) = answer(8 downto 6) then
                            green_out(1) <= '1';
                            correct_pos := correct_pos + 1;
                        else
                            win_flag := '0';
                        end if;
                        
                        if guess(5 downto 3) = answer(5 downto 3) then
                            green_out(2) <= '1';
                            correct_pos := correct_pos + 1;
                        else
                            win_flag := '0';
                        end if;
                        
                        if guess(2 downto 0) = answer(2 downto 0) then
                            green_out(3) <= '1';
                            correct_pos := correct_pos + 1;
                        else
                            win_flag := '0';
                        end if;
                        
                        -- Simple color matching for blue LEDs
                        -- For each position, check if color matches any other position
                        -- Position 0
                        if green_out(0) = '0' and 
                           (guess(11 downto 9) = answer(8 downto 6) or 
                            guess(11 downto 9) = answer(5 downto 3) or 
                            guess(11 downto 9) = answer(2 downto 0)) then
                            blue_out(0) <= '1';
                        end if;
                        
                        -- Position 1
                        if green_out(1) = '0' and 
                           (guess(8 downto 6) = answer(11 downto 9) or 
                            guess(8 downto 6) = answer(5 downto 3) or 
                            guess(8 downto 6) = answer(2 downto 0)) then
                            blue_out(1) <= '1';
                        end if;
                        
                        -- Position 2
                        if green_out(2) = '0' and 
                           (guess(5 downto 3) = answer(11 downto 9) or 
                            guess(5 downto 3) = answer(8 downto 6) or 
                            guess(5 downto 3) = answer(2 downto 0)) then
                            blue_out(2) <= '1';
                        end if;
                        
                        -- Position 3
                        if green_out(3) = '0' and 
                           (guess(2 downto 0) = answer(11 downto 9) or 
                            guess(2 downto 0) = answer(8 downto 6) or 
                            guess(2 downto 0) = answer(5 downto 3)) then
                            blue_out(3) <= '1';
                        end if;
                        
                        -- Check for win
                        if win_flag = '1' then
                            state <= "10"; -- WIN state
                        end if;
                    end if;
                
                when "10" => -- WIN state
                    -- Victory LED flashing pattern - alternating between green and the correct answer
                    if blink = '1' then
                        rgb_out <= "010010010010"; -- All LEDs green (0b010 = green on each LED)
                    else
                        rgb_out <= answer; -- Show the correct answer
                    end if;
                    
                    -- Flash the green indicator LEDs too
                    if blink = '1' then
                        green_out <= "1111"; -- All green indicator LEDs on
                    else
                        green_out <= "0000"; -- All indicator LEDs off
                    end if;
                    
                    blue_out <= (others => '0'); -- No blue LEDs needed in win state
                    buzzer <= blink; -- Activate buzzer in sync with the blinking for victory sound
                
                when "11" => -- RESET state
                    -- Clear all outputs and prepare for new game
                    rgb_out <= (others => '0');
                    green_out <= (others => '0');
                    blue_out <= (others => '0');
                    buzzer <= '0';
                    guess <= (others => '0');
                    answer <= (others => '0');
                    index <= "00";
                    setup_done <= '0';
                    state <= "00"; -- Go back to SET_ANSWER state
                
                when others =>
                    state <= "00"; -- Default case
            end case;
        end if;
    end process;
end Behavioral;