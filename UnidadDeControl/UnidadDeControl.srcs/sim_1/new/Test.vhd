library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_tb is
end Control_tb;

architecture TB of Control_tb is

    ----------------------------------------------------------------
    -- DUT Signals
    ----------------------------------------------------------------
    signal CLK : STD_LOGIC := '0';
    signal Opcode : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal Funct1 : STD_LOGIC := '0';
    signal Funct2 : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
    signal Zero : STD_LOGIC := '0';

    signal RegWrite, WriteSel, PCCLR, PCLD, ResultSrc, MemWrite, ALUSrc : STD_LOGIC;
    signal ALUCtrl, ImmSrc : STD_LOGIC_VECTOR (2 downto 0);
    signal PCSrc : STD_LOGIC_VECTOR (1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    ----------------------------------------------------------------
    -- Local microcode copy (reference model)
    ----------------------------------------------------------------
    type MATRIZ_OP is array (0 TO 31) OF STD_LOGIC_VECTOR(14 downto 0);
    constant MICROCODE_OP : MATRIZ_OP := (
        1 => "101100000000111",
        2 => "101100001000000",
        3 => "101100000001100",
        4 => "101100000101100",
        5 => "101100001011000",
        6 => "001100000101101", -- BEQ
        7 => "101100001001100",
        8 => "111110000001100",
        17 => "101100100000111",
        19 => "101100000010000",
        20 => "101100000111100",
        21 => "101100001101000",
        22 => "111110000001011",
        others => (others => '0')
    );

    type MATRIZ_FUNCT is array (0 TO 6) OF STD_LOGIC_VECTOR(14 downto 0);
    constant MICROCODE_FUNCT : MATRIZ_FUNCT := (
        0 => "100100000000000",
        1 => "100100000010000",
        2 => "100100000100000",
        3 => "100100000110000",
        4 => "100100001000000",
        5 => "100100001010000",
        6 => "100100001100000",
        others => (others => '0')
    );

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    DUT: entity work.Control
        port map (
            CLK => CLK,
            Opcode => Opcode,
            Funct1 => Funct1,
            Funct2 => Funct2,
            Zero => Zero,
            RegWrite => RegWrite,
            WriteSel => WriteSel,
            PCCLR => PCCLR,
            PCLD => PCLD,
            ResultSrc => ResultSrc,
            MemWrite => MemWrite,
            ALUSrc => ALUSrc,
            ALUCtrl => ALUCtrl,
            ImmSrc => ImmSrc,
            PCSrc => PCSrc
        );

    ----------------------------------------------------------------
    -- CLOCK
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
    stim_proc: process

        variable expected : STD_LOGIC_VECTOR(14 downto 0);
        variable idx : integer;

        ----------------------------------------------------------------
        -- CHECK full microcode (except PCSrc override case)
        ----------------------------------------------------------------
        procedure CHECK_MICROCODE is
        begin
            assert RegWrite = expected(14) severity error;
            assert WriteSel = expected(13) severity error;
            assert PCCLR    = expected(12) severity error;
            assert PCLD     = expected(11) severity error;
            assert ResultSrc= expected(8)  severity error;
            assert MemWrite = expected(7)  severity error;
            assert ALUCtrl  = expected(6 downto 4) severity error;
            assert ALUSrc   = expected(3)  severity error;
            assert ImmSrc   = expected(2 downto 0) severity error;
        end procedure;

        ----------------------------------------------------------------
        -- APPLY stimulus
        ----------------------------------------------------------------
        procedure APPLY(
            constant op  : STD_LOGIC_VECTOR(3 downto 0);
            constant f1  : STD_LOGIC;
            constant f2  : STD_LOGIC_VECTOR(1 downto 0);
            constant z   : STD_LOGIC
        ) is
        begin
            Opcode <= op;
            Funct1 <= f1;
            Funct2 <= f2;
            Zero   <= z;

            ------------------------------------------------------------
            -- Rising edge check
            ------------------------------------------------------------
            wait until rising_edge(CLK);
            wait for 1 ns;

            if op = "0000" then
                idx := to_integer(unsigned(f2 & f1));
                expected := MICROCODE_FUNCT(idx);
            else
                idx := to_integer(unsigned(f1 & op));
                expected := MICROCODE_OP(idx);
            end if;

            CHECK_MICROCODE;

            -- PCSrc (before correction)
            assert PCSrc = expected(10 downto 9)
                report "PCSrc mismatch on rising edge" severity error;

            ------------------------------------------------------------
            -- Falling edge check (BEQ correction)
            ------------------------------------------------------------
            wait until falling_edge(CLK);
            wait for 1 ns;

            if (f1 & op) = "00110" and z = '1' then
                assert PCSrc = "01"
                    report "BEQ correction failed (PCSrc not overridden)" severity error;
            else
                assert PCSrc = expected(10 downto 9)
                    report "Unexpected PCSrc change on falling edge" severity error;
            end if;

        end procedure;

    begin

        wait for 20 ns;

        ----------------------------------------------------------------
        -- GENERAL SWEEP
        ----------------------------------------------------------------
        for op in 0 to 15 loop
            for f1 in 0 to 1 loop
                for f2 in 0 to 3 loop
                    APPLY(
                        std_logic_vector(to_unsigned(op,4)),
                        std_logic'val(f1),
                        std_logic_vector(to_unsigned(f2,2)),
                        '0'
                    );
                end loop;
            end loop;
        end loop;

        ----------------------------------------------------------------
        -- BEQ SPECIFIC TESTS
        ----------------------------------------------------------------
        -- BEQ index = 6 → Funct1='0', Opcode="0110"

        -- Case 1: Zero = 0 → no override
        APPLY("0110", '0', "00", '0');

        -- Case 2: Zero = 1 → override expected
        APPLY("0110", '0', "00", '1');

        report "All tests passed!" severity note;

        wait;
    end process;

end TB;