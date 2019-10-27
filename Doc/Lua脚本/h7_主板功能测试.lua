--H7-TOOL���幦�ܳ���
beep()
print("H7-TOOL���幦�ܳ�������Ѽ���")

--����GPIO�������
function test_gpio(void)
	local err
	local terr
	local i
	print("")
	print("----��ʼ����----")
	err=0
	terr=0
--����TVCC���3.3V
	set_tvcc(3.3)

--�任������������ٲ�һ��
	gpio_cfg(0, 0)
	gpio_cfg(1, 1)
	gpio_cfg(2, 0)
	gpio_cfg(3, 1)
	gpio_cfg(4, 0)
	gpio_cfg(5, 1)
	gpio_cfg(6, 0)
	gpio_cfg(7, 1)
	gpio_cfg(8, 0)
	gpio_cfg(9, 1)	
	
	gpio_write(1, 1) if (gpio_read(0)==1) then err=0 else err=1 end
	gpio_write(1, 0) if (gpio_read(0)==1) then err=err+1 end
	if (err == 0) then print("D1->D0 ok") else print("D1->D0 Error") terr=terr+1 end
	
	gpio_write(3, 1) if (gpio_read(2)==1) then err=0 else err=1 end
	gpio_write(3, 0) if (gpio_read(2)==1) then err=err+1 end
	if (err == 0) then print("D3->D2 ok") else print("D3->D2 Error") terr=terr+1 end

	gpio_write(5, 1) if (gpio_read(4)==1) then err=0 else err=1 end
	gpio_write(5, 0) if (gpio_read(4)==1) then err=err+1 end
	if (err == 0) then print("D5->D4 ok") else print("D5->D4 Error") terr=terr+1 end
	
	gpio_write(7, 1) if (gpio_read(6)==1) then err=0 else err=1 end
	gpio_write(7, 0) if (gpio_read(6)==1) then err=err+1 end
	if (err == 0) then print("D7->D6 ok") else print("D7->D6 Error") terr=terr+1 end	

	gpio_write(9, 1) if (gpio_read(8)==1) then err=0 else err=1 end
	gpio_write(9, 0) if (gpio_read(8)==1) then err=err+1 end
	if (err == 0) then print("D9->D8 ok") else print("D9->D8 Error") terr=terr+1 end	
		
--4��GPIO����������Զ�����	
	gpio_cfg(0, 1)	-- ����D0Ϊ���
	gpio_cfg(1, 0)	-- ����D1δ����
	gpio_cfg(2, 1)
	gpio_cfg(3, 0)
	gpio_cfg(4, 1)
	gpio_cfg(5, 0)
	gpio_cfg(6, 1)
	gpio_cfg(7, 0)
	gpio_cfg(8, 1)
	gpio_cfg(9, 0)		
	
	gpio_write(0, 1) if (gpio_read(1)==1) then err=0 else err=1 end
	gpio_write(0, 0) if (gpio_read(1)==1) then err=err+1 end
	if (err == 0) then print("D0->D1 ok") else print("D0->D1 Error") terr=terr+1 end
	
	gpio_write(2, 1) if (gpio_read(3)==1) then err=0 else err=1 end
	gpio_write(2, 0) if (gpio_read(3)==1) then err=err+1 end
	if (err == 0) then print("D2->D3 ok") else print("D2->D3 Error") terr=terr+1 end

	gpio_write(4, 1) if (gpio_read(5)==1) then err=0 else err=1 end
	gpio_write(4, 0) if (gpio_read(5)==1) then err=err+1 end
	if (err == 0) then print("D4->D5 ok") else print("D4->D5 Error") terr=terr+1 end
	
	gpio_write(6, 1) if (gpio_read(7)==1) then err=0 else err=1 end
	gpio_write(6, 0) if (gpio_read(7)==1) then err=err+1 end
	if (err == 0) then print("D6->D7 ok") else print("D6->D7 Error") terr=terr+1 end

	gpio_write(8, 1) if (gpio_read(9)==1) then err=0 else err=1 end
	gpio_write(8, 0) if (gpio_read(9)==1) then err=err+1 end
	if (err == 0) then print("D8->D9 ok") else print("D8->D9 Error") terr=terr+1 end
				
--����CAN				
	gpio_cfg(12, 1)	
	gpio_cfg(13, 0)	
	
	err = 0
	for i=0,10,1 do
		gpio_write(12, 0) delayus(1) if (gpio_read(13)==1) then err=err+1 end
		delayus(100)
		gpio_write(12, 1) delayus(1) if (gpio_read(13)==0) then err=err+1 end
		delayus(100)
	end
	if (err == 0) then print("CANTX->CANRX ok") else print("CANTX->CANRX Error", err) terr=terr+1 end

--����TTL-UART
	gpio_cfg(100, 1)	
	gpio_write(100, 0)
	
	gpio_cfg(10, 1)
	gpio_cfg(11, 0)
	
	err = 0
	for i=0,10,1 do
		gpio_write(10, 0) delayus(10) if (gpio_read(11)==1) then err=err+1 end
		delayus(100)
		gpio_write(10, 1) delayus(10) if (gpio_read(11)==0) then err=err+1 end
		delayus(100)
	end
	if (err == 0) then print("TTL UART ok") else print("TTL UART Error", err) terr=terr+1 end
	
	if (terr > 0) then
		print("*****����ʧ�� terr = ", terr)
		beep()
		delayms(100)
		beep()
		delayms(100)
		beep()	
	else
		print("*****����ͨ��*****")
		beep()	
	end
end

--����ʾ������ADC�ɼ�����ͨ��ģʽ
function start_dso(void)
	print("������ͨ�����ٲ���ģʽ")
	write_reg16(0x01FF, 2) --��ͨ�����ٲ���
	write_reg16(0x0200, 1) -- CH1ѡDC���
	write_reg16(0x0201, 1) -- CH2ѡDC���
	write_reg16(0x0202, 0) -- CH1ͨ������0�������Ŵ�
	write_reg16(0x0203, 0) -- CH2ͨ������0�������Ŵ�
	write_reg16(0x0204, 0) -- CH1ͨ��ֱ��ƫֵ��δ��
	write_reg16(0x0205, 0) -- CH2ͨ��ֱ��ƫֵ��δ��
	write_reg16(0x0206, 12) --����Ƶ��1M
	write_reg16(0x0207, 0) --�������1K
	write_reg16(0x0208, 0) --������ƽ
	write_reg16(0x0209, 50) --����λ��
	write_reg16(0x020A, 0) --����ģʽ 0=�Զ�
	write_reg16(0x020B, 0) --����ͨ��CH1
	write_reg16(0x020C, 0) --��������
	write_reg16(0x020D, 2) --ͨ��ʹ��
	write_reg16(0x020E, 1) --��ʼ�ɼ�
end

function test_ch1ch2(void)
	local err
	local i
	local adc
	local dac
	local errd
--DAC���¹�ϵ
--CH1 4095=12.356V  2500=2.75V  2058=95mV
--CH2(������������200ŷ)	
--CH1��8�������о�
	local dac1 = {2047, -1024, 512, 256, 128, 64, 32, 10}
	local mid1 = {60760, 4666, 60844, 60785, 60634, 60127, 59042, 46390}
	local diff1 = {0.02, 0.2, 0.05, 0.06, 0.10, 0.15, 0.18, 0.32} --����ϵ��
--CH2��8�������о�	
	local dac2 = {4095, 1024, 512, 256, 128, 64, 32, 16}
	local mid2 = {43121, 41400, 37714, 37575, 37556, 37494, 37633, 40601}
	local diff2 = {0.2, 0.1, 0.08, 0.08, 0.08, 0.08, 0.12, 0.15}
		
	print("")
	print("----��ʼʾ������·----")
	start_dso();
	err = 0
	
	dac_on()	--��DAC��Դ������Ϊ��ƽģʽ
	
	print("���ڲ�CH1,DC���...")
	for i=1,8,1 do
		write_reg16(0x0202, i-1) -- CH1ͨ������0-7
		dac = dac1[i] + 2044
		dac_write(dac) delayms(500)	
		adc = read_adc(0)
		errd = mid1[i] * diff1[i];
		if (adc < mid1[i] - errd  or adc > mid1[i] + errd) then 
			err = err + 1
			print("dac=", dac, adc, "error") 
		else
			print("dac=", dac, adc, "ok") 
		end
	end
	
	print("���ڲ�CH2,DC���...")
	for i=1,8,1 do
		write_reg16(0x0203, i-1) -- CH2ͨ������0-7
		dac = dac2[i]
		dac_write(dac) delayms(500)	
		adc = read_adc(1)
		errd = mid2[i] * diff2[i];
		if (adc < mid2[i] - errd  or adc > mid2[i] + errd) then 
			err = err + 1
			print("dac=", dac, adc, "error") 
		else
			print("dac=", dac, adc, "ok") 
		end
	end

	write_reg16(0x0200, 0) -- CH1���AC
	write_reg16(0x0201, 0) -- CH2���AC	
	write_reg16(0x0202, 0) -- CH1ͨ������0
	write_reg16(0x0203, 0) -- CH2ͨ������0
	delayms(2000)
	adc = read_adc(0)
	if (adc < 32768 - 200 or adc > 32768 + 200) then
		print("CH1 AC���", adc, "errpr") 
		err = err + 1
	else
		print("CH1 AC���", adc, "ok") 
	end
	
	adc = read_adc(1)
	if (adc < 32733 - 200 or adc > 32750 + 200) then
		print("CH2 AC���", adc, "errpr") 
		err = err + 1
	else
		print("CH2 AC���", adc, "ok") 
	end	
	
::quit::
--�ɹ���һ����ʧ�ܽ�����
	if (err == 0) then
		print("*****����ͨ��*****")
		beep()
	else
		print("*****����ʧ��*****")
		beep()
		delayms(100)
		beep()
		delayms(100)
		beep()	
	end	
end

function test_tvcc(void)
	local err
	local i
	local adc

	local mid1 = {2485, 1539, 13919, 4167, 43393, 11378, 50701}
	local mid2 = {8157, 4809, 46031, 13299, 43391, 11367, 50469}
	local diff1 = {0.2, 0.2, 0.2, 0.3, 0.1, 0.1, 0.1}
	local diff2 = {0.1, 0.1, 0.1, 0.2, 0.1, 0.1, 0.1}
	local name = {"�߲��ѹ", "�߲����", "TVCC��ѹ", "TVCC����", "NTC ����","12V ��ѹ","USB ��ѹ"}	
	
	print("")
	print("----��ʼ����TVCC NTC ----")
--start_dso();	
	err = 0
	print("TVCC = 120")
	write_tvcc_dac(120)
	
	delayms(1000)
	
	for i = 1,7,1 do
		adc = read_adc(i+1)
		errd = mid1[i] * diff1[i];
		if (adc < mid1[i] - errd  or adc > mid1[i] + errd) then 
			err = err + 1
			print(name[i], adc, "error") 
		else
			print(name[i], adc, "ok") 
		end
	end
	
	print("")
	print("TVCC = 36")
	write_tvcc_dac(36)
	delayms(1000)
	for i = 1,7,1 do
		adc = read_adc(i+1)
		errd = mid2[i] * diff2[i];
		if (adc < mid2[i] - errd  or adc > mid2[i] + errd) then 
			err = err + 1
			print(name[i], adc, "error") 
		else
			print(name[i], adc, "ok") 
		end
	end

::quit::
--�ɹ���һ����ʧ�ܽ�����
	if (err == 0) then
		print("*****����ͨ��*****")
		beep()
	else
		print("*****����ʧ��*****")
		beep()
		delayms(100)
		beep()
		delayms(100)
		beep()	
	end		
end
