use thuongmaidientu
go

-- unrepeatable read
if object_id('USP_QUANLITHUCDON') is not null
	drop proc USP_QUANLITHUCDON
go

-- 0 - thanh cong
-- 1 - that bai

go 
create proc USP_QUANLITHUCDON
	@MADOITAC varchar(50),
	@THUCDON varchar(50),
	@MAMONAN varchar(50),
	@TENMON nvarchar(50),
	@MIEUTA nvarchar(50),
	@GIA float,
	@TINHTRANG nvarchar(50),
	@SOLUONG int,
	@TUYCHON varchar(50),
	@TENTUYCHON nvarchar(50)
as
begin transaction
		if not exists (select * from DOITAC where MADOITAC = @MADOITAC)
		begin
			print N'Không tìm thấy đối tác với mã ' + @MADOITAC
			rollback transaction
			return 1
		end

		if not exists (select * from MONAN where MAMONAN = @MAMONAN and THUCDON = @THUCDON)
		begin
			print N'Không tìm thấy món ăn trong thực đơn'
			rollback transaction
			return 1
		end

		if exists (select * from MONAN where TENMON = @TENMON and MAMONAN <> @MAMONAN and THUCDON = @THUCDON)
		begin
			print N'Món ăn với tên này đã tồn tại trong thực đơn'
			rollback transaction
			return 1
		end

		if (@GIA < 0 or @SOLUONG < 0)
		begin
			print N'Giá và số lượng phải lớn hơn hoặc bằng 0'
			rollback transaction
			return 1
		end

		if not exists (select * from TUYCHON where MATUYCHON=@TUYCHON and TEN=@TENTUYCHON)
		begin
			print N'Tùy chọn không tồn tại'
			rollback transaction
			return 1
		end
		print('end')
		update MONAN set TENMON=@TENMON, MIEUTA=@MIEUTA, GIA=@GIA, TINHTRANG=@TINHTRANG, TUYCHON=@TUYCHON, SOLUONG=@SOLUONG, TENTUYCHON=@TENTUYCHON where MAMONAN=@MAMONAN and THUCDON=@THUCDON
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
set transaction isolation level repeatable read
begin transaction
	begin try
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

		if ((select SOLUONG from MONAN where MAMONAN=@MONAN and THUCDON=@THUCDON) < @SOLUONG)
		begin
			print N'Không đủ số lượng món ăn, vui lòng chọn ít lại'
			rollback transaction
			return 1
		end

		-- delay
		waitfor delay '00:00:08'
		
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
		update MONAN set SOLUONG=((select SOLUONG from MONAN where MAMONAN=@MONAN and THUCDON=@THUCDON) - @SOLUONG) where MAMONAN=@MONAN and THUCDON=@THUCDON
		insert into DONDATHANG values (@MADONDATHANG, @MAKHACHHANG, @MADOITAC, 'null', N'Chờ xác nhận', @THANHTIEN)
		insert into chitietdonhang values (@MACHITIET, @MADONDATHANG, @MAKHACHHANG, @MADOITAC, @MONAN, @SOLUONG, (select top 1 TENQUAN from CUAHANG where MADOITAC=@MADOITAC), (select top 1 DIACHI from CUAHANG where MADOITAC=@MADOITAC))
	end try

	begin catch
		print N'lỗi hệ thống'

		rollback transaction
		return 1
	end catch
commit transaction
return 0
go
