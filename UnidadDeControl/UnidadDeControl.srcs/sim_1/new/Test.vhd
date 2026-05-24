library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_tb is
end Control_tb;

architecture TB of Control_tb is

    ----------------------------------------------------------------
    -- DUT Signals
    ----------------------------------------------------------------
    signal Opcode : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal Funct1 : STD_LOGIC := '0';
    signal Funct2 : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
    signal Zero : STD_LOGIC := '0';

    signal RegWrite, WriteSel, ResultSrc, MemWrite, ALUSrc : STD_LOGIC;
    signal ALUCtrl, ImmSrc : STD_LOGIC_VECTOR (2 downto 0);
    signal PCSrc : STD_LOGIC_VECTOR (1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    ----------------------------------------------------------------
    -- Local microcode copy (reference model)
    ----------------------------------------------------------------
    type MATRIZ_OP is array (0 TO 31) OF STD_LOGIC_VECTOR(12 downto 0);
    constant MICROCODE_OP : MATRIZ_OP := (
        1 =>  "1000001111111", -- LI
        2 =>  "0000010000110", -- ST
        3 =>  "1000000001100", -- ADDI
        4 =>  "1000000101100", -- XORI
        5 =>  "1000001011000", -- SLLI
        6 =>  "0000000100101", -- BEQ: PCSrc indica usar siguiente instrucción por defecto. La corrección se hace en flanco de bajada
        7 =>  "1000001001100", -- SLTI
        8 =>  "1110000001100", -- JALR
        17 => "1000100000111", -- LD
        19 => "1000000011100", -- SUBI
        20 => "1000000111100", -- ANDI
        21 => "1000001101000", -- SRLI
        22 => "1110001111011", -- JAL
        others => (others => '0')
    );

    type MATRIZ_FUNCT is array (0 TO 6) OF STD_LOGIC_VECTOR(12 downto 0);
    constant MICROCODE_FUNCT : MATRIZ_FUNCT := (
        0 => "1000000000000", -- ADD
        1 => "1000000010000", -- SUB
        2 => "1000000100000", -- XOR
        3 => "1000000110000", -- AND
        4 => "1000001000000", -- SLT
        5 => "1000001010000", -- SLL
        6 => "1000001100000", -- SRL
        others => (others => '0')
    );

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    DUT: entity work.Control
        port map (
            Opcode => Opcode,
            Funct1 => Funct1,
            Funct2 => Funct2,
            Zero => Zero,
            RegWrite => RegWrite,
            WriteSel => WriteSel,
            ResultSrc => ResultSrc,
            MemWrite => MemWrite,
            ALUSrc => ALUSrc,
            ALUCtrl => ALUCtrl,
            ImmSrc => ImmSrc,
            PCSrc => PCSrc
        );

    ----------------------------------------------------------------
    -- STIMULUS
    ----------------------------------------------------------------
    stim_proc: process

        variable expected : STD_LOGIC_VECTOR(12 downto 0);
        variable idx : integer;

        ----------------------------------------------------------------
        -- CHECK full microcode (except PCSrc override case)
        ----------------------------------------------------------------
        procedure CHECK_MICROCODE is
        begin
            assert RegWrite = expected(12) severity error;
            assert WriteSel = expected(11) severity error;
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
            wait for 2 ns;

            if op = "0000" then
                idx := to_integer(unsigned(f2 & f1));
                expected := MICROCODE_FUNCT(idx);
            else
                idx := to_integer(unsigned(f1 & op));
                expected := MICROCODE_OP(idx);
            end if;

            CHECK_MICROCODE;

            if (f1 & op) = "00110" and z = '1' then
                assert PCSrc = "01"
                    report "BEQ correction failed (PCSrc not overridden)" severity error;
            else
                assert PCSrc = expected(10 downto 9)
                    report "Unexpected PCSrc change" severity error;
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