library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ArchReg_tb is
end ArchReg_tb;

architecture TB of ArchReg_tb is

    -- DUT Signals
    signal CLK  : STD_LOGIC := '0';
    signal WE3  : STD_LOGIC := '0';
    signal A1   : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal A2   : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal A3   : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal WD3  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal RD1  : STD_LOGIC_VECTOR (7 downto 0);
    signal RD2  : STD_LOGIC_VECTOR (7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate DUT
    DUT: entity work.ArchReg
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

    ----------------------------------------------------------------
    -- Clock Generation
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
    -- Reusable Procedures
    ----------------------------------------------------------------
    
    -- Write Procedure
    procedure WRITE_REG(
        signal addr : out STD_LOGIC_VECTOR(2 downto 0);
        signal data : out STD_LOGIC_VECTOR(7 downto 0);
        signal we   : out STD_LOGIC;
        constant reg_addr : STD_LOGIC_VECTOR(2 downto 0);
        constant reg_data : STD_LOGIC_VECTOR(7 downto 0)
    ) is
    begin
        addr <= reg_addr;
        data <= reg_data;
        we   <= '1';
        wait until rising_edge(CLK);
        we   <= '0';
    end procedure;

    -- Read + Check Procedure
    procedure CHECK_REG(
        signal addr : out STD_LOGIC_VECTOR(2 downto 0);
        signal data_out : in STD_LOGIC_VECTOR(7 downto 0);
        constant reg_addr : STD_LOGIC_VECTOR(2 downto 0);
        constant expected : STD_LOGIC_VECTOR(7 downto 0)
    ) is
    begin
        addr <= reg_addr;
        wait for 1 ns; -- allow combinational read
        
        assert data_out = expected
        report "Mismatch at register " & integer'image(to_integer(unsigned(reg_addr)))
        severity error;
    end procedure;

    ----------------------------------------------------------------
    -- Stimulus Process
    ----------------------------------------------------------------
    stim_proc: process
    begin

        ----------------------------------------------------------------
        -- Reset-like initial delay
        ----------------------------------------------------------------
        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 1: Basic Write/Read
        ----------------------------------------------------------------
        WRITE_REG(A3, WD3, WE3, "001", x"AA");
        CHECK_REG(A1, RD1, "001", x"AA");

        ----------------------------------------------------------------
        -- TEST 2: Multiple Writes
        ----------------------------------------------------------------
        WRITE_REG(A3, WD3, WE3, "010", x"55");
        WRITE_REG(A3, WD3, WE3, "011", x"FF");

        CHECK_REG(A1, RD1, "010", x"55");
        CHECK_REG(A1, RD1, "011", x"FF");

        ----------------------------------------------------------------
        -- TEST 3: Register 0 should NOT change
        ----------------------------------------------------------------
        WRITE_REG(A3, WD3, WE3, "000", x"FF"); -- should be ignored
        CHECK_REG(A1, RD1, "000", x"00");

        ----------------------------------------------------------------
        -- TEST 4: Dual Read
        ----------------------------------------------------------------
        A1 <= "001";
        A2 <= "010";
        wait for 1 ns;

        assert RD1 = x"AA" report "RD1 mismatch" severity error;
        assert RD2 = x"55" report "RD2 mismatch" severity error;

        ----------------------------------------------------------------
        -- TEST DONE
        ----------------------------------------------------------------
        report "All tests completed successfully!" severity note;

        wait;
    end process;

end TB;