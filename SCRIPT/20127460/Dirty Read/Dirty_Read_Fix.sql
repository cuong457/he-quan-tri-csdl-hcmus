use thuongmaidientu
go

-- dirty read + unrepeatable read
if object_id('USP_QUANLICUAHANG') is not null
	drop proc USP_QUANLICUAHANG
go

-- thay doi ten cua hang, giomocua, giodongcua, tinhtrang
-- 0 - thanh cong
-- 1 - that bai
go 
create proc USP_QUANLICUAHANG
	@MADOITAC varchar(50),
	@MACUAHANG varchar(50),
	@TENQUAN nvarchar(50), 
	@GIOMOCUA time,
	@GIODONGCUA time,
	@TINHTRANG nvarchar(50)
as
begin transaction
	begin try
		if not exists (select * from DOITAC where MADOITAC = @MADOITAC)
		begin
			print N'Không tìm thấy đối tác với mã ' + @MADOITAC
			rollback transaction
			return 1
		end

		if not exists (select * from CUAHANG where MADOITAC = @MADOITAC and MACUAHANG = @MACUAHANG)
		begin
			print N'Cửa hàng cần cập nhật không tồn tại'
			rollback transaction
			return 1
		end
		
		if (@TENQUAN = null or @GIOMOCUA = null or @GIODONGCUA = null or @TINHTRANG = null)
		begin
			print N'Thông tin cửa hàng không được null'
			rollback transaction
			return 1
		end

		if (datepart(hour, @GIOMOCUA) > datepart(hour, @GIODONGCUA))
		begin
			print N'Giờ mở cửa phải trước giờ đóng cửa'
			rollback transaction
			return 1
		end

		if (@TINHTRANG not in (N'Đang mở', N'Ngừng nhận đơn'))
		begin
			print N'Tình trạng cửa hàng là Đang mở hoặc Ngừng nhận đơn'
			rollback transaction
			return 1
		end

		update CUAHANG set TENQUAN = @TENQUAN where MADOITAC = @MADOITAC
		update CUAHANG set GIOMOCUA = @GIOMOCUA, GIODONGCUA = @GIODONGCUA, TINHTRANG = @TINHTRANG where MADOITAC = @MADOITAC and MACUAHANG = @MACUAHANG

		waitfor delay '00:00:08'
		declare @updatetime int
		set @updatetime = (select datediff(day, (select CAPNHAT from CUAHANG where MADOITAC = @MADOITAC and MACUAHANG = @MACUAHANG), getDate()))
		if (@updatetime < 30)
		begin
			print N'Không được cập nhật tên trong vòng 30 ngày'
			rollback transaction
			return 1
		end
		update CUAHANG set CAPNHAT = getDate() where MADOITAC = @MADOITAC and MACUAHANG = @MACUAHANG
	end try

	begin catch
		print N'lỗi hệ thống'
		rollback transaction
		return 1
	end catch
commit transaction
return 0
go

if object_id('USP_DATHANG') is not null
	drop proc USP_DATHANG
go

go 
create proc USP_DATHANG
	@MACHITIET varchar(50),
	@MONAN varchar(50),
	@THUCDON varchar(50),
	@SOLUONG int,
	@MADONDATHANG varchar(50),
	@MAKHACHHANG varchar(50),
	@MADOITAC varchar(50),
	@THANHTIEN float
as
set transaction isolation level read committed
begin transaction
	begin try
	select * from monan
		if not exists (select * from MONAN where MAMONAN = @MONAN and THUCDON=@THUCDON)
		begin
			print N'Không tìm món ăn này'
			rollback transaction
			return 1
		end
		if not exists (select * from KHACHHANG where MAKHACHHANG = @MAKHACHHANG)
		begin
			print N'Không tìm thấy khách hàng với mã ' + @MAKHACHHANG
			rollback transaction
			return 1
		end

		if not exists (select * from DOITAC where MADOITAC = @MADOITAC)
		begin
			print N'Không tìm thấy đối tác với mã ' + @MADOITAC
			rollback transaction
			return 1
		end

		select * from monan 
		if ((select SOLUONG from MONAN where MAMONAN=@MONAN and THUCDON=@THUCDON) < @SOLUONG)
		begin
			print N'Không đủ số lượng món ăn, vui lòng chọn ít lại'
			rollback transaction
			return 1
		end
		
		if (@THANHTIEN < 0)
		begin
			print N'Số tiền phải lớn hơn 0vnđ'
			rollback transaction
			return 1
		end
		if (@SOLUONG < 0)
		begin
			print N'Số lượng phải lớn hơn 0'
			rollback transaction
			return 1
		end
		--select * from dondathang
		insert into DONDATHANG values (@MADONDATHANG, @MAKHACHHANG, @MADOITAC, 'null', N'Chờ xác nhận', @THANHTIEN)
		insert into chitietdonhang values (@MACHITIET, @MADONDATHANG, @MAKHACHHANG, @MADOITAC, @MONAN, @SOLUONG, (select top 1 TENQUAN from CUAHANG where MADOITAC=@MADOITAC), (select top 1 DIACHI from CUAHANG where MADOITAC=@MADOITAC))
		update MONAN set SOLUONG=((select SOLUONG from MONAN where MAMONAN=@MONAN and THUCDON=@THUCDON) - @SOLUONG)
	end try

	begin catch
		print N'lỗi hệ thống'

		rollback transaction
		return 1
	end catch
commit transaction
return 0
go
