library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real."log2";
use IEEE.math_real."floor";

entity ArchReg_tb is
end ArchReg_tb;

architecture TB of ArchReg_tb is

    constant N : INTEGER := 8;
    constant ADDR_WIDTH : INTEGER := integer(floor(log2(real(N - 1)))) + 1;

    signal CLK : STD_LOGIC := '0';
    signal WE3 : STD_LOGIC := '0';
    signal A1  : STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0) := (others => '0');
    signal A2  : STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0) := (others => '0');
    signal A3  : STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0) := (others => '0');
    signal WD3 : STD_LOGIC_VECTOR (N-1 downto 0) := (others => '0');
    signal RD1 : STD_LOGIC_VECTOR (N-1 downto 0);
    signal RD2 : STD_LOGIC_VECTOR (N-1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: entity work.ArchReg
        generic map (
            N => N
        )
        port map (
            CLK => CLK,
            WE3 => WE3,
            A1  => A1,
            A2  => A2,
            A3  => A3,
            WD3 => WD3,
            RD1 => RD1,
            RD2 => RD2
        );

    clk_process : process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    stim_proc: process
        procedure WRITE_REG(
            constant addr : INTEGER;
            constant data : INTEGER
        ) is
        begin
            A3  <= std_logic_vector(to_unsigned(addr, ADDR_WIDTH));
            WD3 <= std_logic_vector(to_unsigned(data, N));
            WE3 <= '1';
            wait until rising_edge(CLK);
            WE3 <= '0';
        end procedure;

        procedure CHECK_REG(
            constant addr : INTEGER;
            constant expected : INTEGER
        ) is
        begin
            A1 <= std_logic_vector(to_unsigned(addr, ADDR_WIDTH));
            wait for 1 ns; -- async read

            assert RD1 = std_logic_vector(to_unsigned(expected, N))
            report "Mismatch at register " & integer'image(addr)
            severity error;
        end procedure;

    begin
        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 1: Basic Write/Read
        ----------------------------------------------------------------
        WRITE_REG(1, 16#AA#);
        CHECK_REG(1, 16#AA#);

        ----------------------------------------------------------------
        -- TEST 2: Multiple Writes
        ----------------------------------------------------------------
        WRITE_REG(2, 16#55#);
        WRITE_REG(3, 16#FF#);

        CHECK_REG(2, 16#55#);
        CHECK_REG(3, 16#FF#);

        ----------------------------------------------------------------
        -- TEST 3: Register 0 must remain 0
        ----------------------------------------------------------------
        WRITE_REG(0, 16#FF#); -- ignored
        CHECK_REG(0, 0);

        ----------------------------------------------------------------
        -- TEST 4: Dual Read
        ----------------------------------------------------------------
        A1 <= std_logic_vector(to_unsigned(1, ADDR_WIDTH));
        A2 <= std_logic_vector(to_unsigned(2, ADDR_WIDTH));
        wait for 1 ns;

        assert RD1 = std_logic_vector(to_unsigned(16#AA#, N))
            report "RD1 mismatch" severity error;

        assert RD2 = std_logic_vector(to_unsigned(16#55#, N))
            report "RD2 mismatch" severity error;

        ----------------------------------------------------------------
        -- TEST 5: FULL SWEEP (scales with N)
        ----------------------------------------------------------------
        for i in 1 to N-1 loop
            WRITE_REG(i, i*3);
        end loop;

        for i in 1 to N-1 loop
            CHECK_REG(i, i*3);
        end loop;

        ----------------------------------------------------------------
        -- TEST 6: EDGE VALUES
        ----------------------------------------------------------------
        WRITE_REG(N-1, 2**N - 1);
        CHECK_REG(N-1, 2**N - 1);

        ----------------------------------------------------------------
        -- DONE
        ----------------------------------------------------------------
        report "All tests completed" severity note;

        wait;
    end process;

end TB;