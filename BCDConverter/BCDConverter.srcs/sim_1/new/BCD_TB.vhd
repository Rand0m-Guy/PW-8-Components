library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCDConverter_tb is
end BCDConverter_tb;

architecture TB of BCDConverter_tb is

    ----------------------------------------------------------------
    -- CONSTANTS
    ----------------------------------------------------------------
    constant N : INTEGER := 8;

    ----------------------------------------------------------------
    -- DUT SIGNALS
    ----------------------------------------------------------------
    signal VAL1, VAL2 : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');

    signal ISSIG1, ISSIG2 : STD_LOGIC := '0';

    signal S11, S12, S13 : STD_LOGIC_VECTOR(3 downto 0);
    signal S21, S22, S23 : STD_LOGIC_VECTOR(3 downto 0);

    signal SIGN1, SIGN2 : STD_LOGIC;

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    DUT : entity work.BCDConverter
        generic map(
            N => 8,
            SCRATCH_SPACE_SIZE => 20
        )
        port map(
            VAL1 => VAL1,
            VAL2 => VAL2,
            ISSIG1 => ISSIG1,
            ISSIG2 => ISSIG2,
            S11 => S11,
            S12 => S12,
            S13 => S13,
            S21 => S21,
            S22 => S22,
            S23 => S23,
            SIGN1 => SIGN1,
            SIGN2 => SIGN2
        );

    ----------------------------------------------------------------
    -- STIMULUS
    ----------------------------------------------------------------
    stim_proc : process

        ----------------------------------------------------------------
        -- CHECK VALUE 1
        ----------------------------------------------------------------
        procedure CHECK1(
            constant exp_s11 : STD_LOGIC_VECTOR(3 downto 0);
            constant exp_s12 : STD_LOGIC_VECTOR(3 downto 0);
            constant exp_s13 : STD_LOGIC_VECTOR(3 downto 0);
            constant exp_sign : STD_LOGIC
        ) is
        begin
            assert S11 = exp_s11
                report ("Mismatch on S11. Got: " & integer'image(to_integer(unsigned(S11))) & "; expected: " &
                integer'image(to_integer(unsigned(exp_s11))))
                severity error;

            assert S12 = exp_s12
                report ("Mismatch on S12. Got: " & integer'image(to_integer(unsigned(S12))) & "; expected: " &
                integer'image(to_integer(unsigned(exp_s12))))
                severity error;

            assert S13 = exp_s13
                report ("Mismatch on S13. Got: " & integer'image(to_integer(unsigned(S13))) & "; expected: " &
                integer'image(to_integer(unsigned(exp_s13))))
                severity error;

            assert SIGN1 = exp_sign
                report ("Mismatch on SIGN1. Got: " & std_logic'image(SIGN1) & "; expected: " &
                std_logic'image(exp_sign))
                severity error;
        end procedure;

        ----------------------------------------------------------------
        -- CHECK VALUE 2
        ----------------------------------------------------------------
        procedure CHECK2(
            constant exp_s21 : STD_LOGIC_VECTOR(3 downto 0);
            constant exp_s22 : STD_LOGIC_VECTOR(3 downto 0);
            constant exp_s23 : STD_LOGIC_VECTOR(3 downto 0);
            constant exp_sign : STD_LOGIC
        ) is
        begin
            assert S21 = exp_s21
                report ("Mismatch on S21. Got: " & integer'image(to_integer(unsigned(S21))) & "; expected: " &
                integer'image(to_integer(unsigned(exp_s21))))
                severity error;

            assert S22 = exp_s22
                report ("Mismatch on S22. Got: " & integer'image(to_integer(unsigned(S22))) & "; expected: " &
                integer'image(to_integer(unsigned(exp_s22))))
                severity error;

            assert S23 = exp_s23
                report ("Mismatch on S23. Got: " & integer'image(to_integer(unsigned(S23))) & "; expected: " &
                integer'image(to_integer(unsigned(exp_s23))))
                severity error;

            assert SIGN2 = exp_sign
                report ("Mismatch on SIGN2. Got: " & std_logic'image(SIGN2) & "; expected: " &
                std_logic'image(exp_sign))
                severity error;
        end procedure;

    begin

        ----------------------------------------------------------------
        -- TEST 1 : ZERO
        ----------------------------------------------------------------
        VAL1 <= x"00";
        VAL2 <= x"00";

        ISSIG1 <= '0';
        ISSIG2 <= '0';

        wait for 10 ns;

        CHECK1("0000", "0000", "0000", '0');
        CHECK2("0000", "0000", "0000", '0');

        ----------------------------------------------------------------
        -- TEST 2 : POSITIVE VALUES
        -- 25 and 99
        ----------------------------------------------------------------
        VAL1 <= std_logic_vector(to_unsigned(25, 8));
        VAL2 <= std_logic_vector(to_unsigned(99, 8));

        wait for 10 ns;

        -- 025
        CHECK1("0000", "0010", "0101", '0');

        -- 099
        CHECK2("0000", "1001", "1001", '0');

        ----------------------------------------------------------------
        -- TEST 3 : MAX UNSIGNED VALUE
        -- 255
        ----------------------------------------------------------------
        VAL1 <= x"FF";
        ISSIG1 <= '0';

        wait for 10 ns;

        CHECK1("0010", "0101", "0101", '0');

        ----------------------------------------------------------------
        -- TEST 4 : NEGATIVE NUMBER
        -- -5 = 11111011
        ----------------------------------------------------------------
        VAL1 <= std_logic_vector(to_signed(-5, 8));
        ISSIG1 <= '1';

        wait for 10 ns;

        CHECK1("0000", "0000", "0101", '1');

        ----------------------------------------------------------------
        -- TEST 5 : NEGATIVE NUMBER
        -- -42
        ----------------------------------------------------------------
        VAL1 <= std_logic_vector(to_signed(-42, 8));
        ISSIG1 <= '1';

        wait for 10 ns;

        CHECK1("0000", "0100", "0010", '1');

        ----------------------------------------------------------------
        -- TEST 6 : SPECIAL CASE -128
        ----------------------------------------------------------------
        VAL1 <= "10000000";
        ISSIG1 <= '1';

        wait for 10 ns;

        CHECK1("0001", "0010", "1000", '1');

        ----------------------------------------------------------------
        -- TEST 7 : MIXED VALUES
        -- VAL1 = 7
        -- VAL2 = -12
        ----------------------------------------------------------------
        VAL1 <= std_logic_vector(to_unsigned(7, 8));
        VAL2 <= std_logic_vector(to_signed(-12, 8));

        ISSIG1 <= '0';
        ISSIG2 <= '1';

        wait for 10 ns;

        CHECK1("0000", "0000", "0111", '0');

        CHECK2("0000", "0001", "0010", '1');

        ----------------------------------------------------------------
        -- TEST 8 : RANDOM VALUES
        ----------------------------------------------------------------
        VAL1 <= std_logic_vector(to_unsigned(123, 8));
        VAL2 <= std_logic_vector(to_unsigned(200, 8));

        ISSIG1 <= '0';
        ISSIG2 <= '0';

        wait for 10 ns;

        CHECK1("0001", "0010", "0011", '0');

        CHECK2("0010", "0000", "0000", '0');

        ----------------------------------------------------------------
        -- END
        ----------------------------------------------------------------
        report "All BCDConverter tests passed!"
            severity note;

        wait;

    end process;

end TB;