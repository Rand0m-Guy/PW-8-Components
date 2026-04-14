library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemInstruc is
    generic(
        N : integer := 8;
        INSTR_SIZE : integer := 16 
    );
    Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
           RD : out STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0));
end MemInstruc;

architecture Behavioral of MemInstruc is

type MATRIZ is array (0 TO 2**N - 1) OF STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
constant MEM_INSTR : MATRIZ := (
    -- AQUI VA EL PROGRAMA A CORRER
    others => (others => '0')
);

begin
    RD <= MEM_INSTR(to_integer(unsigned(A)));
end Behavioral;
