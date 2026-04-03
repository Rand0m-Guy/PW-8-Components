library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_pw8_tb is
end alu_pw8_tb;

architecture tb of alu_pw8_tb is

    constant N : integer := 8;

    component alu_pw8
        generic ( N : INTEGER := 8 );
        Port ( A        : in  STD_LOGIC_VECTOR (N-1 downto 0);
               B        : in  STD_LOGIC_VECTOR (N-1 downto 0);
               ALU_ctrl : in  STD_LOGIC_VECTOR (2 downto 0);
               zero     : out STD_LOGIC;
               ALURes   : out STD_LOGIC_VECTOR (N-1 downto 0));
    end component;

    signal A        : STD_LOGIC_VECTOR (N-1 downto 0) := (others => '0');
    signal B        : STD_LOGIC_VECTOR (N-1 downto 0) := (others => '0');
    signal ALU_ctrl : STD_LOGIC_VECTOR (2 downto 0)   := (others => '0');
    signal zero     : STD_LOGIC;
    signal ALURes   : STD_LOGIC_VECTOR (N-1 downto 0);

begin

    UUT: alu_pw8
        generic map ( N => N )
        port map (
            A        => A,
            B        => B,
            ALU_ctrl => ALU_ctrl,
            zero     => zero,
            ALURes   => ALURes
        );

    process
    begin

        -- =====================
        -- 000: SUMA A + B
        -- =====================
        A <= std_logic_vector(to_signed(10, N));   -- 10
        B <= std_logic_vector(to_signed(5, N));    -- 5
        ALU_ctrl <= "000";
        wait for 50 ns;
        -- Esperado: ALURes = 15, zero = 0
        wait;
    end process;

end tb;