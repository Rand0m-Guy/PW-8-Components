library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package RV8Integer is
    subtype rv8int is integer range -128 to 127;
    subtype urv8int is integer range 0 to 255;
    
    function to_urv8int (val: STD_LOGIC_VECTOR) return urv8int; -- STD_LOGIC_VECTOR => urv8int
end RV8Integer;

package body RV8Integer is
    function to_urv8int (val: STD_LOGIC_VECTOR)
            return urv8int is
        variable maxCheck: urv8int;
        variable result: urv8int;
    begin
        result := 0;
        
        maxCheck := (val'HIGH - val'LOW);
        if (maxCheck > 7) then maxCheck := 7; -- Únicamente revisa vectores de máximo 8 bits
        end if;
        
        for i in (val'LOW + maxCheck) downto (val'LOW) loop
            result := result*2;
            if(val(i)='1') THEN result := result+1;
            end if;
        end loop;
        return result;
    end to_urv8int;
end RV8Integer; 