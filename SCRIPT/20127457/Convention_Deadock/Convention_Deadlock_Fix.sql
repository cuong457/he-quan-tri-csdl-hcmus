
--Đồ án 3
use thuongmaidientu
go

if object_id('USP_CAPNHATCUAHANG') is not null
	drop proc USP_CAPNHATCUAHANG
go
create proc USP_CAPNHATCUAHANG
	 @MaDoiTac varchar(50),
	 @MaCuaHang varchar(50),
	 @TenQuan nvarchar(50),
	 @ChiNhanThu int,
	 @DiaChi nvarchar(50),
	 @GioMoCua time,
	 @GioDongCua time,
	 @TinhTrang nvarchar(50)
as
set transaction isolation level REPEATABLE READ
begin transaction
	begin try
		if (@MaDoiTac is null or @MaCuaHang is null or @TenQuan is null or @ChiNhanThu is null or 
			@DiaChi is null or @GioMoCua is null or @GioDongCua is null or @TinhTrang is null)
		begin
			print N'Thông tin cung cấp rỗng'
			rollback transaction
			return 1
		end

		if not exists (select * from DOITAC DT
						where DT.MADOITAC = @MaDoiTac)
		begin
			print N'Mã đối tác không tồn tại'
			rollback transaction
			return 1
		end
		
		if not exists (select * from CUAHANG CH
						where CH.MACUAHANG = @MaCuaHang and CH.MADOITAC = @MaDoiTac)
		begin
			print N'Mã cửa hàng không tồn tại'
			rollback transaction
			return 1
		end

		if datediff(HOUR, @GioMoCua, @GioDongCua) < 1
		begin
			print N'Giờ mở cửa và đóng cửa không hợp lệ'
			rollback transaction
			return 1
		end
	
	end try

	begin catch
		print N'Lỗi'
		rollback transaction
		return 1
	end catch

	--Để test
	waitfor delay '0:0:05'

	update CUAHANG
	set TENQUAN = @TenQuan, CHINHANHTHU =  @ChiNhanThu, DIACHI = @DiaChi,
		GIOMOCUA = @GioMoCua, GIODONGCUA = @GioDongCua, TINHTRANG = @TinhTrang
	where MADOITAC = @MaDoiTac and MACUAHANG = @MaCuaHang

commit transaction
return 0
go
