----------------------------------------------------------------------------------
-- Testbench para PC_pw8
-- DUT: PC_pw8 (generic N=8)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_PC_pw8 is
end tb_PC_pw8;

architecture sim of tb_PC_pw8 is

    constant N : integer := 8;
    constant T : time    := 10 ns;

    signal PCNext : std_logic_vector(N-1 downto 0) := (others => '0');
    signal CLR    : std_logic := '0';
    signal CLK    : std_logic := '0';
    signal PC_out : std_logic_vector(N-1 downto 0);

begin

    -- Instancia del DUT
    DUT: entity work.PC_pw8
        generic map(N => N)
        port map(
            PCNext => PCNext,
            CLR    => CLR,
            CLK    => CLK,
            PC_out => PC_out
        );

    -- Reloj
    clk_proc: process
    begin
        CLK <= '0'; wait for T/2;
        CLK <= '1'; wait for T/2;
    end process;

    -- Estimulos
    stim: process
    begin
        -- 1) Reset inicial: PC_out debe ser 0x00
        PCNext <= x"24";
        wait for T;
        
        CLR <= '1';
        wait for 2*T;

        report "Simulacion completada" severity note;
        wait;
    end process;

end sim;