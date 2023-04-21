----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dang Wen
-- 
-- Create Date: 2022/05/12 15:19:51
-- Design Name: 
-- Module Name: sat5g_rx_pusch_ofdm_fft_removecp - Behavioral
-- Project Name: sat5g_rx_pusch_ofdm_fft
-- Target Devices: 
-- Tool Versions: 2018.1
-- Description: Remove CP - generate valid signal
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 1.00 - File created.
-- Revision 1.10 - FFT window start at the center of CP.
-- Revision 1.20 - Revisied for phase compensation.
-- Revision 1.30 - 3/16/2023 Fixed the condition clearing accumulative phase.
-- v2.00 2323/4/7  Add 60kHz support.
-- v2.1.0 2023/4/20 Comment debug blocks which remove all of the CP for debugging.
-- v2.2.0 2023/4/21 fixed unexpected output duty cycle.
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sat5g_rx_pusch_ofdm_fft_removecp is
  Port (
    i_clk               : in  std_logic;
    i_rst               : in  std_logic;
    iv_slot_idx         : in  std_logic_vector(6 downto 0);
    i_scs               : in  std_logic;    -- 0:60kHz, 1:120kHz
    i_slotStart         : in  std_logic;
    iv_cp_type          : in  std_logic_vector(1 downto 0);   -- 1x: extended;    0x:normal;  01:544,288,288  00: 288,288,288
    ov_k_start          : out std_logic_vector(16 downto 0);
    ov_N_cp             : out std_logic_vector(10 downto 0);
    o_decpst_en         : out std_logic;  -- enable signal for de-compensate module
    o_data_valid        : out std_logic
   );
end sat5g_rx_pusch_ofdm_fft_removecp;

architecture Behavioral of sat5g_rx_pusch_ofdm_fft_removecp is

signal  en_cnt:         std_logic;
signal  en_cnt_d1:      std_logic;
signal  cnt_slot:       std_logic_vector(14 downto 0);
signal  cnt_sym:        std_logic_vector(11 downto 0);

signal  cp_type:        std_logic_vector(1 downto 0);
signal  flag_notfirst:  std_logic;
signal  len_cp:         std_logic_vector(9 downto 0);
signal  len_slot:       std_logic_vector(14 downto 0);

signal slot_start_d1    : std_logic;
signal data_valid:      std_logic;
signal data_valid_d1:   std_logic;

signal vld_start    : std_logic_vector(11 downto 0);
signal vld_end      : std_logic_vector(11 downto 0);
signal len_symb     : std_logic_vector(11 downto 0);
--------------------------------------------------------------------------
-- Phase compensate
signal slot_idx         : std_logic_vector(6 downto 0); -- 0:80-1
signal slot_subframe    : std_logic_vector(2 downto 0); -- 0:8-1
signal symb_slot        : std_logic_vector(3 downto 0); -- 0:12-1
signal cpst_k_start     : std_logic_vector(16 downto 0);
signal cpst_k_start_d1  : std_logic_vector(16 downto 0);

begin

slot_idx_reg_proc: process(i_clk, i_rst)
begin
    if(i_rst='1') then
        slot_idx        <=  (others=>'0');
        slot_subframe   <=  (others=>'0');
    elsif(i_clk'event and i_clk='1') then
        if(i_slotStart='1') then
            slot_idx    <=  iv_slot_idx;
        end if;
        slot_subframe   <=  slot_idx(2 downto 0);   -- mod 8.
    end if;
end process;

cp_len_gen:process(i_clk,i_rst)
begin
if(i_rst='1') then
    len_cp      <= (others=>'0');
    len_slot    <= (others=>'0');
    len_symb    <=  (others=>'0');
    vld_start   <=  (others=>'0');
    vld_end     <=  (others=>'0');
else
    if(i_clk'event and i_clk='1') then
        if(i_scs='0') then
            len_cp      <=  "0111111111";    -- 1024/2-1
            len_slot    <=  "111011111111111";   -- 30720-1
            len_symb    <=  "10" & len_cp;
--            vld_start   <=  "000" & len_cp(9 downto 1);   -- Half CP
--            vld_end     <=  "100" & len_cp(9 downto 1);  -- +2048
            --------
            vld_start   <=  "00" & len_cp;
            vld_end     <=  "10" & len_cp;  -- +2048
            --------
        else
            len_cp      <=  "0011111111";    -- 1024/4-1
            len_slot    <=  "011101111111111";   -- 15360-1
            len_symb    <=  "01" & len_cp;
--            vld_start   <=  "000" & len_cp(9 downto 1);   -- Half CP
--            vld_end     <=  "010" & len_cp(9 downto 1);  -- +1024
            --------
            vld_start   <=  "00" & len_cp;
            vld_end     <=  "01" & len_cp;  -- +1024
            --------
        end if;
    end if;
end if;
end process;

-- produce the length of counter
count_gen:process(i_clk,i_rst)
begin
if(i_rst='1') then
    flag_notfirst   <= '0';
    en_cnt          <= '0';
    cnt_sym         <= (others=>'0');
    cnt_slot        <= (others=>'0');
    en_cnt_d1       <= '0';
    o_decpst_en     <= '0';
    slot_start_d1   <= '0';
else
    if(i_clk'event and i_clk='1') then
        slot_start_d1   <=  i_slotStart;
        if(i_slotStart='1') then
            cp_type <= iv_cp_type;
            en_cnt <= '1';
        elsif(cnt_slot = len_slot) then
            en_cnt <= '0';
        end if;
        en_cnt_d1 <= en_cnt;
        o_decpst_en <= en_cnt_d1;
        
        if(cnt_slot = len_slot) then
            flag_notfirst <= '0';
        else
            if(cnt_sym = len_symb) then
                flag_notfirst <= '1';
            end if;
        end if;
        
        if(en_cnt='1') then
            if(cnt_sym = len_symb or (i_slotStart='1'and slot_start_d1='0')) then
                cnt_sym <= (others=>'0');
            else
                cnt_sym <= cnt_sym+1;
            end if;
            
            if(cnt_slot = len_slot or (i_slotStart='1'and slot_start_d1='0')) then
                cnt_slot <= (others=>'0');
            else
                cnt_slot <= cnt_slot+1;
            end if;
        end if;
    end if;
end if;
end process;

valid_gen:process(i_clk,i_rst)
begin
if(i_rst='1') then
    ov_k_start  <= (others=>'0');
    ov_N_cp     <= (others=>'0');
    o_data_valid <= '0';
    data_valid  <= '0';
    data_valid_d1 <= '0';
else
    if(i_clk'event and i_clk='1') then
        ov_k_start  <= cpst_k_start_d1;
        ov_N_cp <= b"001_0000_0000";
        if(cnt_sym>=vld_start and cnt_sym <vld_end and cnt_sym/=0) then   -- generate high signal at the position of data.
            data_valid <= '1';
        else
            data_valid <= '0';
        end if;
        
        data_valid_d1 <= data_valid;
        o_data_valid <= data_valid_d1;
    end if;
end if;
end process;

symb_idx_proc: process(i_clk, i_rst)
begin
    if(i_rst='1') then
        symb_slot   <=  (others=>'0');
    elsif(i_clk'event and i_clk='1') then
        if(symb_slot=12) then
            symb_slot   <=  (others=>'0');
        elsif(cnt_sym =vld_end) then
            symb_slot   <=  symb_slot+1;
        end if;
    end if;
end process;

comp_proc: process(i_clk,i_rst)
begin
    if(i_rst='1') then
        cpst_k_start    <=  (others=>'0');
        cpst_k_start_d1 <=  (others=>'0');
    elsif(i_clk'event and i_clk='1') then
        if(symb_slot=12 and slot_subframe=0) then   -- Almost 1 slot latency.
            cpst_k_start    <=  (others=>'0');
        elsif(cnt_sym =vld_end) then
            cpst_k_start    <= cpst_k_start + b"0_0000_0101_0000_0000"; -- Nu + N_cp, 1024+256=1280
        end if;
        cpst_k_start_d1 <=  cpst_k_start;
    end if;
end process;


end Behavioral;
