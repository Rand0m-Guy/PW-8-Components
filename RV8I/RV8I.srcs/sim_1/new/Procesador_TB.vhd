library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Procesador_tb is
end Procesador_tb;

architecture TB of Procesador_tb is

    ----------------------------------------------------------------
    -- DUT Signals
    ----------------------------------------------------------------
    signal CLK : STD_LOGIC := '0';
    signal CLR : STD_LOGIC := '0';

    signal A  : STD_LOGIC_VECTOR (7 downto 0);
    signal WD : STD_LOGIC_VECTOR (7 downto 0);
    
    signal TEST_PC : STD_LOGIC_VECTOR (7 downto 0);
    signal MICRO_TEST : STD_LOGIC_VECTOR (14 downto 0);
    signal INSTR_TEST : STD_LOGIC_VECTOR (15 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    ----------------------------------------------------------------
    -- DUT INSTANCE
    ----------------------------------------------------------------
    DUT: entity work.Procesador
        port map (
            CLK => CLK,
            CLR => CLR,
            A   => A,
            WD  => WD,
            PC_OUT_TEST => TEST_PC,
            MICRO_INSTR_TEST => MICRO_TEST,
            INSTR_TEST => INSTR_TEST
        );

    ----------------------------------------------------------------
    -- CLOCK GENERATION
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- STIMULUS
    ----------------------------------------------------------------
    stim_proc : process
    begin

        ------------------------------------------------------------
        -- INITIAL RESET (clean start)
        ------------------------------------------------------------
        CLR <= '1';
        wait for 20 ns;
        CLR <= '0';

        ------------------------------------------------------------
        -- LET PROGRAM RUN
        ------------------------------------------------------------
        wait for 1000 ns;

        ------------------------------------------------------------
        -- SIMULATE BUTTON PRESS (PCCLR trigger)
        ------------------------------------------------------------
        CLR <= '1';
        wait for CLK_PERIOD;  -- one full clock pulse
        CLR <= '0';

        ------------------------------------------------------------
        -- RUN AGAIN
        ------------------------------------------------------------
        wait for 10000 ns;

        report "Simulation finished successfully" severity note;

        wait;
    end process;

    ----------------------------------------------------------------
    -- MONITOR (VERY USEFUL IN VIVADO CONSOLE)
    ----------------------------------------------------------------
    monitor_proc : process(CLK)
    begin
        if rising_edge(CLK) then
            report "t=" & time'image(now) &
                   " | A=" & integer'image(to_integer(unsigned(A))) &
                   " | WD=" & integer'image(to_integer(unsigned(WD))) &
                   " | PC=" & integer'image(to_integer(unsigned(TEST_PC))) &
                   " | MicroInstr=" & integer'image(to_integer(unsigned(MICRO_TEST))) &
                   " | Instr=" & integer'image(to_integer(unsigned(INSTR_TEST)));
        end if;
    end process;

end TB;