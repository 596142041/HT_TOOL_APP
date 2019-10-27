beep()

--����2�㷽����ֵ
function cacul(x1,y1,x2,y2,x)
	local ff

	if (x2 == x1) then
		ff = 0
	else
		ff = y1 + ((y2 - y1) * (x - x1)) / (x2 - x1);
	end
	return ff
end
	
--����0-7ͨ���ĵ�ѹ V
function ad7606_volt(ch)
	local X1 = {39,		39,		39,		36,		73,		74,		73,		71}
	local Y1 = {0,		0,		0,		0,		0,		0,		0,		0}
	local X2 = {29417,	29362,	29520,	29396,	29407,	29407,	29407,	29407}
	local Y2 = {8.999,	8.999,	8.999,	8.999,	8.999,	8.999,	8.999,	8.999}
	local adc
	local volt
	
	adc = ex_adc(ch)
	volt = cacul(X1[ch+1], Y1[ch+1], X2[ch+1], Y2[ch+1], adc)
	return volt
end

--����0-7ͨ���ĵ��� mA
function ad7606_curr(ch)
	local X1 = {75,		75,		74,		72,		73,		74,		73,		71}
	local Y1 = {0,		0,		0,		0,		0,		0,		0,		0}
	local X2 = {29417,	29362,	29520,	29396,	29407,	29812,	31786,	29017}
	local Y2 = {8.999,	8.999,	8.999,	8.999,	8.999,	454.64,	19.482,	88.900}
	local adc
	local curr
	
	adc = ex_adc(ch)
	curr = cacul(X1[ch+1], Y1[ch+1], X2[ch+1], Y2[ch+1], adc)
	return curr
end

--����DAC8563�����ѹ����λV, ����
function dac8563_volt(volt)
	local X1 = 1000
	local Y1 = -9.8551
	local X2 = 32767
	local Y2 = -0.003030
	local X3 = 64000
	local Y3 = 9.6802
	local dac
	
	if (volt < Y2) then
		dac = cacul(Y1,X1,Y2,X2,volt)
	else
		dac = cacul(Y2,X2,Y3,X3,volt)
	end
	ex_dac(0, dac)
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


--���һ��ֵ�Ƿ��ڹ��Χ 1��ʾerr 0��ʾok
function check_err(data, mid, diff)
	local re
	local dd

	if (mid < 0) then
		dd = -mid * diff
	else
		dd = mid * diff
	end
	
	if ((data >= mid - dd) and  (data <= mid + dd)) then
		re = 0
	else
		re = 1
	end
	return re
end

--�ر����еļ̵���
function colse_all_y(void)
	return ch 
end

--�ɹ���һ����ʧ�ܽ�����
function disp_result(err)
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

--У׼��ʼ��
function calib_init(void)
	write_tvcc_dac(43) --����TVCC���3.3V
	delayms(100)
	ex_start()	--��ر�ȫ���̵���
	start_dso()	--������ͨ�����ٲɼ�ģʽ
	write_reg16(0xBFFF, 1)	--��У׼����
end

--У׼TVCC���õ�ѹ�Ͳ�����ѹ
function calib_tvcc_volt(void)
	local adc
	local volt
	local err
	
	err = 0
	--��У׼TVCC���õ�ѹ�ͼ���ѹ
	print("")
	print("---У׼TVCC---")
	
	---��1��	
	write_tvcc_dac(36)	--4.4V����
	delayms(1500)
	volt = ad7606_volt(0) --��ȡAD7606 TVCC��ѹ
	if (check_err(volt, 4.416, 0.05)==1) then
		print("SET= 36", "ʵ�ʵ�ѹ=", volt, "err")
		err = err + 1
	else
		print("SET= 36", "ʵ�ʵ�ѹ=", volt, "ok")
		write_regfloat(0xC0C0, 36)
		write_regfloat(0xC0C2, volt)		
	end

	adc = read_adc(4) --��cpu adc tvcc��ѹ
	if (check_err(adc, 46368, 0.1)==1) then
		print("TVCC Volt ADC     =", adc, "err")
		err = err + 1
	else
		print("TVCC Volt ADC     =", adc, "ok")
		write_regfloat(0xC0AC, adc)
		write_regfloat(0xC0AE, volt)		
	end	

	adc = read_adc(2) --��cpu adc �߲��ѹ
	if (check_err(adc, 8117, 0.1)==1) then
		print("HighSide Volt ADC =", adc, "err")
		err = err + 1
	else
		print("HighSide Volt ADC =", adc, "ok")
		write_regfloat(0xC084, adc)
		write_regfloat(0xC086, volt)		
	end	

	---��2��	
	print("")
	write_tvcc_dac(100)
	delayms(1500)
	volt = ad7606_volt(0) --��ȡAD7606 TVCC ��ѹ
	if (check_err(volt, 1.59, 0.1)==1) then
		print("SET=100", "ʵ�ʵ�ѹ=", volt, "err")
		err = err + 1
	else
		print("SET=100", "ʵ�ʵ�ѹ=", volt, "ok")
		write_regfloat(0xC0C4, 100)
		write_regfloat(0xC0C6, volt)		
	end

	adc = read_adc(4) --��cpu adc tvcc��ѹ
	if (check_err(adc, 16679, 0.1)==1) then
		print("TVCC Volt ADC     =", adc, "err")
		err = err + 1
	else
		print("TVCC Volt ADC     =", adc, "ok")
		write_regfloat(0xC0A8, adc)
		write_regfloat(0xC0AA, volt)			
	end	

	adc = read_adc(2) --��cpu adc �߲��ѹ
	if (check_err(adc, 2879, 0.1)==1) then
		print("HighSide Volt ADC =", adc, "err")
		err = err + 1
	else
		print("HighSide Volt ADC =", adc, "ok")
		write_regfloat(0xC080, adc)
		write_regfloat(0xC082, volt)			
	end	
	
	--�ָ�TVCC��ѹ3.3������Ͳ�����
	write_tvcc_dac(47)		
	return err
end

--У׼CPU��DAC�����ѹ�͵���
function calib_dac(void)
	local i
	local err
	local volt
	local curr
	local dac
	local dac_tab = {500, 1500, 2500, 3500}
	local volt_mid = {-9.176, -3.235, 2.711, 8.661}
	local curr_mid = {2.592, 7.723, 12.857, 17.992}
	local volt_err = 0.1
	local curr_err = 0.1
	
	err = 0
	dac_on()	--��DAC��Դ������Ϊֱ�����
	delayms(100)
	
	print("")
	print("---У׼DAC��ѹ�͵���---")
	for i = 0, 3, 1 do
		dac = dac_tab[i + 1]
		dac_write(dac)	--CPU DAC���
		delayms(500)
		
		volt = ad7606_volt(1)
		if (check_err(volt, volt_mid[i + 1], volt_err) == 1) then
			print("DAC��ѹ", dac, volt, "err")
			err = err + 1
		else
			print("DAC��ѹ", dac, volt, "ok")
			write_reg16(0xC0C8 + i * 2,  dac)
			write_reg16(0xC0C9 + i * 2,  volt * 1000)	
		end

		curr = ad7606_curr(6)  --20mA����
		if (check_err(curr, curr_mid[i + 1], curr_err) == 1) then
			print("DAC����", dac, curr, "err")
			err = err + 1
		else
			print("DAC����", dac, curr, "ok")
			write_reg16(0xC0D0 + i * 2,  dac)
			write_reg16(0xC0D1 + i * 2,  curr * 1000)			
		end		
	end
	return err
end

--У׼ʾ��������
function calib_ch1ch2(void)
	local i
	local err
	local volt
	local adc
	local ch_tab = {9.0, 6.0, 3.0, 1.5, 0.75, 0.375, 0.170, 0.09}
	local zero_mid = {32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768}
	local full_mid = {53641, 60506, 60629, 60686, 60857, 60915, 58393, 60166}	
	local adc_err1 = 0.22
	local adc_err2 = 0.12
	
	close_all()
	ex_dout(4,1)
		
	print("")
	print("---У׼ʾ������ѹ---")	
	err = 0
	print("����У׼��λ")
	for i = 0, 7, 1 do
		write_reg16(0x0202, i) -- CH1ͨ������0�������Ŵ�
		write_reg16(0x0203, i) -- CH2ͨ������0�������Ŵ�
		
		if (i == 0) then
			delayms(1200)
		else
			delayms(1200)
		end
		adc = read_adc(0)	
		if (check_err(adc, zero_mid[i + 1], adc_err1)==1) then
			print("  CH1", i, adc, "err")
			err = err + 1
		else
			print("  CH1", i, adc, "ok")
			write_regfloat(0xC000 + 8 * i, adc)
			write_regfloat(0xC002 + 8 * i, 0)		
		end			

		adc = read_adc(1)	
		if (check_err(adc, zero_mid[i + 1], adc_err1)==1) then
			print("  CH2", i, adc, "err")
			err = err + 1
		else		
			print("  CH2", i, adc, "ok")
			write_regfloat(0xC040 + 8 * i, adc)
			write_regfloat(0xC042 + 8 * i, 0)
		end
	end	
	
	if (err > 0) then 
		goto quit
	end

	close_all()
	ex_dout(12,1)
	ex_dout(13,1)	
	ex_dout(14,1)	
	delayms(1000)
			
	print("У׼��λ")
	for i = 0, 7, 1 do
		write_reg16(0x0202, i) -- CH1ͨ������0�������Ŵ�
		write_reg16(0x0203, i) -- CH2ͨ������0�������Ŵ�
		
		dac8563_volt(ch_tab[i + 1])
		
		delayms(1000)
		adc = read_adc(0)	
		volt = ad7606_volt(1)
		if (check_err(adc, full_mid[i + 1], adc_err2)==1) then
			print("  CH1", i, volt, adc, "err")
			err = err + 1
		else		
			print("  CH1", i, volt, adc, "ok")
			write_regfloat(0xC004 + 8 * i, adc)
			write_regfloat(0xC006 + 8 * i, volt)
		end
		
		adc = read_adc(1)	
		volt = ad7606_volt(1)
		if (check_err(adc, full_mid[i + 1], adc_err2)==1) then
			print("  CH2", i, volt, adc, "err")
			err = err + 1
		else		
			print("  CH2", i, volt, adc, "ok")
			write_regfloat(0xC044 + 8 * i, adc)
			write_regfloat(0xC046 + 8 * i, volt)
		end
	end

::quit::	
	if (err > 0)	
	return err
end

--У׼tvcc�����͸߲����
function calib_curr(void)
	local i
	local err
	local curr
	local adc
	local set_tabe1 = {0, 0.15 * 10, 0.3*10, 0.4*10}
	local high_mid1 = {160, 7700, 15330, 20296}
	local tvcc_mid = {477, 21458, 42877, 56882}
	local adc_err1 = {0.5,0.1,0.1,0.1}
	
	local set_tabe2 = {0, 0.03 * 50, 0.05*50, 0.09 * 50}		
	local high_mid2 = {1300, 16421, 26873, 48841}	
	local adc_err2 = {0.9,0.1,0.1,0.1}
	local volt
	
	print("")
	print("---У׼TVCC�����͸߲����---")	
	err = 0
	
	close_all()
	ex_dout(20,1)
	ex_dout(21,1)		
		
	--TVCC�����͸߲������ͬ���Ȳ�1.2A����
	print("---1.2A---")	
	write_reg16(0x0211, 1) --1.2A���� HIGH_SIDE
	for i = 0, 3, 1 do
		volt = set_tabe1[i+1]
		print("�����ѹ", volt)
		if (volt == 0) then
			ex_dout(20,0)
			ex_dout(21,0)
	
			ex_dout(22,0)
			ex_dout(23,0)
			set_tvcc(5)	--����TVCC�����ѹ5v У׼0λ
			delayms(1000)
		else
			ex_dout(20,1)
			ex_dout(21,1)
					
			set_tvcc(volt)	--����TVCC�����ѹ�����ص���Ϊ10ŷ
			ex_dout(23,0) 
			ex_dout(22,1)  --ѡ��10ŷ����
		end
		
		delayms(1000)
		
		if (volt == 0) then
			curr = 0
		else
			curr = ad7606_curr(5)	--10ŷ���أ������
		end

		adc = read_adc(3)	--3=�߲����cpu ADC
		if (check_err(adc, high_mid1[i + 1], adc_err1[i + 1])==1) then
			print("  �߲����", curr, adc, "err")
			err = err + 1
		else
			print("  �߲����", curr, adc, "ok")
			write_regfloat(0xC098 + 4 * i, adc)
			write_regfloat(0xC09A + 4 * i, curr)		
		end			

		adc = read_adc(5)	--5=tvcc����
		if (check_err(adc, tvcc_mid[i + 1], adc_err1[i + 1])==1) then
			print("  TVCC����", curr, adc, "err")
			err = err + 1
		else
			print("  TVCC����", curr, adc, "ok")
			write_regfloat(0xC0B0 + 4 * i, adc)
			write_regfloat(0xC0B2 + 4 * i, curr)		
		end	
	end		
	
	--�߲������ͬ����߲����100����
	print("")
	print("---120mA---")	
	write_reg16(0x0211, 0) --120mA���� HIGH_SIDE
	for i = 0, 3, 1 do
		volt = set_tabe2[i+1]
		print("�����ѹ", volt)
		if (volt == 0) then
			ex_dout(22,0)
			ex_dout(23,0)
		else
			set_tvcc(volt)	--����TVCC�����ѹ�����ص���Ϊ10ŷ
			ex_dout(22,0) 
			ex_dout(23,1)--ѡ��50ŷ����
		end
		
		delayms(1000)
		
		if (volt == 0) then
			curr = 0
		else
			curr = ad7606_curr(7)	--50ŷ���أ������
		end

		adc = read_adc(3)	--3=�߲����cpu ADC
		if (check_err(adc, high_mid2[i + 1], adc_err2[i + 1])==1) then
			print("  �߲����", curr, adc, "err")
			err = err + 1
		else
			print("  �߲����", curr, adc, "ok")
			write_regfloat(0xC088 + 4 * i, adc)
			write_regfloat(0xC08A + 4 * i, curr)		
		end			
	end		
		
	return err
end

--У׼NTC
function calib_ntc(void)
	local i
	local err
	local adc
	local ref = {0.0003, 0.0222, 9.9732, 99.958}
	local Y = {5,6,16,17}
	local adc_mid = {90, 283, 43376, 62376}
	local adc_err = {0.5, 0.5, 0.1, 0.1}
	
	print("")
	print("---У׼NTC---")	
	err = 0
	
	for i=0,3,1 do
		close_all()
		ex_dout(Y[i+1],1)
		delayms(1000)
		adc = read_adc(6)	--6=NTC adc
		if (check_err(adc, adc_mid[i+1], adc_err[i+1])==1) then	
			print("  ����", ref[i+1], adc, "err")
			err = err + 1
		else
			print("  ����", ref[i+1], adc, "ok")
			write_regfloat(0xC0D8+4*i, adc)
			write_regfloat(0xC0DA+4*i, ref[i+1])		
		end	
	end
	return err
end

--�ر����еļ̵���
function close_all(void)
	local i
	
	for i=0,23,1 do
		ex_dout(i, 0)
	end
end
	
--����������
function test_calib(void)
	local err
	local time1
	local time2
	
	time1 = get_runtime()
	
	print(time1)
	
	err = 0
	--calib_init()
	
	close_all()
	ex_dout(20,1)
	ex_dout(21,1)
	err = err + calib_tvcc_volt() --У׼TVCC��ѹ
	if (err > 0) then
		goto quit
	end
	
	close_all()
	ex_dout(0,1)
	ex_dout(19,1)	
	err = err + calib_dac() --У׼DAC
	if (err > 0) then
		goto quit
	end
	
	err = err + calib_ch1ch2() --У׼ʾ����
	if (err > 0) then
		goto quit
	end	
	
	err = err + calib_curr() --У׼TVCC�����͸߲����
	if (err > 0) then
		goto quit
	end

	err = err + calib_ntc() --У׼ntc
	if (err > 0) then
		goto quit
	end
	
	save_param()	--���������eeprom
	
::quit::	
	disp_result(err)
	
	close_all()
	
	time2 = get_runtime()
	print("����ʱ��: ", (time2 - time1) / 1000)
end

	calib_init()
	