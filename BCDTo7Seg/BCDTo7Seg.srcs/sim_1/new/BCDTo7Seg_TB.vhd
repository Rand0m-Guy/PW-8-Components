library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCDTo7Seg_tb is
end BCDTo7Seg_tb;

architecture TB of BCDTo7Seg_tb is

    ----------------------------------------------------------------
    -- DUT SIGNALS
    ----------------------------------------------------------------
    signal CLK : STD_LOGIC := '0';

    signal val1_2, val1_1, val1_0 : STD_LOGIC_VECTOR(3 downto 0);
    signal val2_2, val2_1, val2_0 : STD_LOGIC_VECTOR(3 downto 0);

    signal disp_val   : STD_LOGIC_VECTOR(6 downto 0);
    signal disp_index : STD_LOGIC_VECTOR(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    DUT : entity work.BCDTo7Seg
        port map(
            CLK        => CLK,
            val1_2     => val1_2,
            val1_1     => val1_1,
            val1_0     => val1_0,
            val2_2     => val2_2,
            val2_1     => val2_1,
            val2_0     => val2_0,
            disp_val   => disp_val,
            disp_index => disp_index
        );

    ----------------------------------------------------------------
    -- CLOCK
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;

            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- STIMULUS
    ----------------------------------------------------------------
    stim_proc : process

        ----------------------------------------------------------------
        -- CHECK DISPLAY
        ----------------------------------------------------------------
        procedure CHECK_DISPLAY(
            constant expected_index : STD_LOGIC_VECTOR(7 downto 0);
            constant expected_value : STD_LOGIC_VECTOR(6 downto 0)
        ) is
        begin

            assert disp_index = expected_index
                report (
                    "Mismatch on disp_index. Got: " &
                    integer'image(to_integer(unsigned(disp_index))) &
                    "; expected: " &
                    integer'image(to_integer(unsigned(expected_index)))
                )
                severity error;

            assert disp_val = expected_value
                report (
                    "Mismatch on disp_val. Got: " &
                    integer'image(to_integer(unsigned(disp_val))) &
                    "; expected: " &
                    integer'image(to_integer(unsigned(expected_value)))
                )
                severity error;

        end procedure;

    begin

        ----------------------------------------------------------------
        -- INITIAL VALUES
        ----------------------------------------------------------------
        -- Displayed number 123
        val1_2 <= "0001";
        val1_1 <= "0010";
        val1_0 <= "0011";

        -- Displayed number 456
        val2_2 <= "0100";
        val2_1 <= "0101";
        val2_0 <= "0110";

        ----------------------------------------------------------------
        -- COUNTER = 0
        -- minus sign
        ----------------------------------------------------------------
        wait until rising_edge(CLK);
        wait for 1 ns;

        CHECK_DISPLAY(
            "01000000",
            "1001111"
        );

        ----------------------------------------------------------------
        -- COUNTER = 1
        ----------------------------------------------------------------
        wait until rising_edge(CLK);
        wait for 1 ns;

        CHECK_DISPLAY(
            "00100000",
            "0010010"
        );

        ----------------------------------------------------------------
        -- COUNTER = 2
        ----------------------------------------------------------------
        wait until rising_edge(CLK);
        wait for 1 ns;

        CHECK_DISPLAY(
            "00010000",
            "0000110"
        );

        ----------------------------------------------------------------
        -- COUNTER = 3
        ----------------------------------------------------------------
        wait until rising_edge(CLK);
        wait for 1 ns;

        CHECK_DISPLAY(
            "00001000",
            "1111110"
        );

        ----------------------------------------------------------------
        -- COUNTER = 4
        ----------------------------------------------------------------
        wait until rising_edge(CLK);
        wait for 1 ns;

        CHECK_DISPLAY(
            "00000100",
            "1001100"
        );

        ----------------------------------------------------------------
        -- COUNTER = 5
        ----------------------------------------------------------------
        wait until rising_edge(CLK);
        wait for 1 ns;

        CHECK_DISPLAY(
            "00000010",
            "0100100"
        );

        ----------------------------------------------------------------
        -- COUNTER = 6
        ----------------------------------------------------------------
        wait until rising_edge(CLK);
        wait for 1 ns;

        CHECK_DISPLAY(
            "00000001",
            "0100000"
        );

        ----------------------------------------------------------------
        -- WRAP TEST
        ----------------------------------------------------------------
        wait until rising_edge(CLK);
        wait for 1 ns;

        CHECK_DISPLAY(
            "10000000",
            "1111110"
        );

        ----------------------------------------------------------------
        -- END
        ----------------------------------------------------------------
        report "All BCDTo7Seg tests passed!"
            severity note;

        wait;

    end process;

end TB;