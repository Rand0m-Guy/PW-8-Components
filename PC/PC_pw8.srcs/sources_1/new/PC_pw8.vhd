----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.04.2026 22:33:07
-- Design Name: 
-- Module Name: PC_pw8 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PC_pw8 is
generic(N:integer:=8);
    Port ( PCNext : in STD_LOGIC_VECTOR (N-1 downto 0);
           LD : in STD_LOGIC;
           CLR : in STD_LOGIC;
           CLK : in STD_LOGIC;
           PC_out : out STD_LOGIC_VECTOR (N-1 downto 0));
end PC_pw8;

architecture Behavioral of PC_pw8 is
    signal pc_reg : std_logic_vector(N-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                pc_reg<=(others => '0');
            elsif ld = '1' then
                pc_reg <= PCNext;
            end if;
        end if;
    end process;
    PC_out <= pc_reg;

end Behavioral;
