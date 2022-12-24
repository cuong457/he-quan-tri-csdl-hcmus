
--Đồ Án 3

use thuongmaidientu
go

if object_id('USP_CAPNHATTRANGTHAI_DT') is not null
	drop proc USP_CAPNHATTRANGTHAI_DT
go
create proc USP_CAPNHATTRANGTHAI_DT
	@KhachHang varchar(50),
	@DoiTac varchar(50),
	@MaDon varchar(50),
	@TinhTrang nvarchar(50)
as
set transaction isolation level REPEATABLE READ
begin transaction
	begin try
		if (@KhachHang is null or @DoiTac is null or @MaDon is null or @TinhTrang is null)
		begin
			print N'Thông tin cung cấp rỗng'
			rollback transaction
			return 1
		end

		if not exists (select * from KHACHHANG KH with (XLOCK)
						where KH.MAKHACHHANG = @KhachHang)
		begin
			print N'Mã khách hàng không tồn tại'
			rollback transaction
			return 1
		end

		--Để test
		WAITFOR DELAY '0:0:05'
		
		if not exists (select * from DOITAC DT with (XLOCK)
						where DT.MADOITAC = @DoiTac)
		begin
			print N'Mã đối tác không tồn tại'
			rollback transaction
			return 1
		end

		if not exists (select * from CHITIETDONHANG CTDH where CTDH.MADON = @MaDon)
		begin
			print N'Mã đơn hàng không tồn tại'
			rollback transaction
			return 1
		end

	
	end try

	begin catch
		print N'Lỗi'
		rollback transaction
		return 1
	end catch	

	update DONDATHANG
	set TINHTRANG = @TinhTrang
	where KHACHHANG = @KhachHang 
			and DOITAC = @DoiTac 
			and MADON = @MaDon

commit transaction
return 0
go

if object_id('USP_CAPNHATTRANGTHAI_TX') is not null
	drop proc USP_CAPNHATTRANGTHAI_TX
go
create proc USP_CAPNHATTRANGTHAI_TX
	@KhachHang varchar(50),
	@DoiTac varchar(50),
	@MaDon varchar(50),
	@TinhTrang nvarchar(50)
as
set transaction isolation level REPEATABLE READ
begin transaction
	begin try
		if (@KhachHang is null or @DoiTac is null or @MaDon is null or @TinhTrang is null)
		begin
			print N'Thông tin cung cấp rỗng'
			rollback transaction
			return 1
		end

		if not exists (select * from DOITAC DT with (XLOCK)
						where DT.MADOITAC = @DoiTac)
		begin
			print N'Mã đối tác không tồn tại'
			rollback transaction
			return 1
		end

		--Để test
		WAITFOR DELAY '0:0:05'
		
		if not exists (select * from KHACHHANG KH with (XLOCK)
						where KH.MAKHACHHANG = @KhachHang)
		begin
			print N'Mã khách hàng không tồn tại'
			rollback transaction
			return 1
		end
		
		if not exists (select * from CHITIETDONHANG CTDH where CTDH.MADON = @MaDon)
		begin
			print N'Mã đơn hàng không tồn tại'
			rollback transaction
			return 1
		end

	end try

	begin catch
		print N'Lỗi'
		rollback transaction
		return 1
	end catch

	update DONDATHANG
	set TINHTRANG = @TinhTrang
	where KHACHHANG = @KhachHang 
			and DOITAC = @DoiTac 
			and MADON = @MaDon
	
commit transaction
return 0
go