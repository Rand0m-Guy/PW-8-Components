library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.RV8Integer.ALL;

entity ArchReg is
    Port ( CLK : in STD_LOGIC;
           WE3 : in STD_LOGIC;
           A1,A2,A3 : in STD_LOGIC_VECTOR (2 downto 0);
           WD3 : in STD_LOGIC_VECTOR (7 downto 0);
           RD1,RD2 : out STD_LOGIC_VECTOR (7 downto 0));
end ArchReg;

architecture Comportamiento of ArchReg is

type MATRIZ is array (0 TO 7) OF STD_LOGIC_VECTOR(7 downto 0);
signal REGISTROS: MATRIZ := ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"); -- Inicializamos archivo de registros en cero

begin

    process(CLK)
    begin
        if (CLK'event and CLK='1') then
            if (WE3='1' and A3 /= "000") then -- Escritura, ignorando registro 0
                REGISTROS(to_urv8int(A3)) <= WD3;
            end if;
        end if; 
    end process;
    
    -- Proceso de lectura. Realmente no afecta en caso de que se haya hecho escritura
    RD1 <= REGISTROS(to_urv8int(A1));
    RD2 <= REGISTROS(to_urv8int(A2));

end Comportamiento;
