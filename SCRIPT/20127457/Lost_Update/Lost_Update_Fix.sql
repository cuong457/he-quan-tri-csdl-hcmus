
--Đồ Án 3

use thuongmaidientu
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

		-- Test
		WAITFOR DELAY '0:0:05'

		update MONAN set SOLUONG=((select SOLUONG from MONAN where MAMONAN=@MONAN and THUCDON=@THUCDON) - @SOLUONG) 
			where MAMONAN=@MONAN and THUCDON=@THUCDON

		insert into DONDATHANG values (@MADONDATHANG, @MAKHACHHANG, @MADOITAC, 'TX001', N'Chờ xác nhận', @THANHTIEN)
		insert into CHITIETDONHANG values (@MACHITIET, @MADONDATHANG, @MAKHACHHANG, @MADOITAC, @MONAN, @SOLUONG, 
											(select top 1 TENQUAN from DOITAC where MADOITAC=@MADOITAC), 
											(select top 1 DIACHI from DOITAC where MADOITAC=@MADOITAC))
		
	end try

	begin catch
		print N'lỗi hệ thống'

		rollback transaction
		return 1
	end catch
commit transaction
return 0
go



if object_id('USP_DATHANG_1') is not null
	drop proc USP_DATHANG_1
go

go 
create proc USP_DATHANG_1
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

		
		
		update MONAN set SOLUONG=((select SOLUONG from MONAN where MAMONAN=@MONAN and THUCDON=@THUCDON) - @SOLUONG) 
			where MAMONAN=@MONAN and THUCDON=@THUCDON

		-- Test
		WAITFOR DELAY '0:0:05'

		insert into DONDATHANG values (@MADONDATHANG, @MAKHACHHANG, @MADOITAC, 'TX001', N'Chờ xác nhận', @THANHTIEN)
		insert into CHITIETDONHANG values (@MACHITIET, @MADONDATHANG, @MAKHACHHANG, @MADOITAC, @MONAN, @SOLUONG, 
											(select top 1 TENQUAN from DOITAC where MADOITAC=@MADOITAC), 
											(select top 1 DIACHI from DOITAC where MADOITAC=@MADOITAC))

	end try

	begin catch
		print N'lỗi hệ thống'

		rollback transaction
		return 1
	end catch
commit transaction
return 0
go
