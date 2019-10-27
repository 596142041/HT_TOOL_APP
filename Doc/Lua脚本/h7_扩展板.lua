beep()
--����ת�Ӱ壬ѭ�����
function test_ledout(void)
	local i
	local err
	local fmc
	local flag
	
	print("")
	print("----��ʼ����ת�Ӱ�(���+FMC��������)----")

--����TVCC���
	write_tvcc_dac(47)

--����D7-D0Ϊ���
	gpio_cfg(0, 1)
	gpio_cfg(1, 1)
	gpio_cfg(2, 1)
	gpio_cfg(3, 1)
	gpio_cfg(4, 1)
	gpio_cfg(5, 1)
	gpio_cfg(6, 1)
	gpio_cfg(7, 1)
--ȫ��
	for i=0,7,1 do
		gpio_write(i, 0)		
	end
--ѭ������
	flag = 1
	err = 0
	for i=0,7,1 do
		gpio_write(i, 1) 	
		delayms(100)	
		fmc = read_bus() % 256
		printhex(fmc, 1)
		if (fmc ~= (flag)) then
			err = err + 1
		end	
		flag = flag * 2
		gpio_write(i, 0) 	
		delayms(100)
	end	
--ȫ������
	for i=0,7,1 do
		gpio_write(i, 1)	
	end

--�ɹ���һ����ʧ�ܽ�����
	if (err == 0) then
		print("����ͨ��")
		beep()
	else
		print("����ʧ��")
		beep()
		delayms(100)
		beep()
		delayms(100)
		beep()	
	end
end

--������չ��̵���
function test_extio_open_do(void)
	local i
	
	print("���δ�24���̵��� - ��ʼ")
	beep()
	extio_start()
	for i=0,23,1 do	
		print(i)
		extio_set_do(i, 1)
		delayms(500)
	end
	print("���δ�24���̵��� - ����")
end

--������չ��̵���
function test_extio_close_do(void)
	local i
	
	print("���ιر�24���̵��� - ��ʼ")
	beep()
	extio_start()
	for i=0,23,1 do	
		print(i)
		extio_set_do(i, 1)
		delayms(500)
	end
	print("���ιر�24���̵��� - ����")
end

--������չ��DI
function test_extio_di(void)
	local i
	
	print("������չ��DI")
	beep()
	for i=0,15,1 do	
		print(extio_get_di(i))
	end
end

--������չ��ADC
function test_extio_adc(void)
	local i
	
	print("������չ��ADC")
	beep()
	for i=0,7,1 do	
		print(extio_get_adc(i))
	end
end

--����ת�Ӱ壬ѭ�����
function test_swd(void)
	local err
	local id
	local str
	
	print("")
	print("----��ʼ��SWD����----")
	err = 0
	swd_init(3.3)     --����SWD��3.3V��ѹ
	id = swd_getid()  --��ID
	printhex(id,4)	
	if (id ~= 0x0BB11477) then 
		err = err + 1
	end
	
	swd_write(0x20000000, "12345678")
	str = swd_read(0x20000000, 8)
	print(str)
	if (str ~= "12345678") then
		err = err + 1
	end
	
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
