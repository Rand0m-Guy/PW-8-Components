library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Procesador_tb is
end Procesador_tb;

architecture Behavioral of Procesador_tb is

    -- ========= DUT SIGNALS =========
    signal CLK : STD_LOGIC := '0';
    signal CLR : STD_LOGIC := '0';

    signal DISP_SEL : STD_LOGIC_VECTOR(7 downto 0);
    signal DISP_VAL : STD_LOGIC_VECTOR(6 downto 0);
    signal INS_INDICATOR : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    -- ========= DUT =========
    DUT : entity work.Procesador
        port map(
            CLK           => CLK,
            CLR           => CLR,
            DISP_SEL      => DISP_SEL,
            DISP_VAL      => DISP_VAL,
            INS_INDICATOR => INS_INDICATOR
        );

    -- ========= CLOCK =========
    clk_process : process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;

            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- ========= STIMULUS =========
    stim_proc : process
    begin

        ------------------------------------------------
        -- INITIAL RESET
        ------------------------------------------------
        report "INITIAL RESET";

        CLR <= '1';

        -- Hold reset for multiple cycles
        wait for 4 * CLK_PERIOD;

        CLR <= '0';

        ------------------------------------------------
        -- LET CPU RUN
        ------------------------------------------------
        report "RUNNING";

        wait for 10 * CLK_PERIOD;

        ------------------------------------------------
        -- SECOND RESET TEST
        ------------------------------------------------
        report "SECOND RESET";

        CLR <= '1';

        wait for 4 * CLK_PERIOD;

        CLR <= '0';

        ------------------------------------------------
        -- RUN AGAIN
        ------------------------------------------------
        report "RUNNING AGAIN";

        wait for 15 * CLK_PERIOD;

        ------------------------------------------------
        -- END SIMULATION
        ------------------------------------------------
        report "END SIMULATION";

        wait;
    end process;

end Behavioral;