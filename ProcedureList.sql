﻿use thuongmaidientu
go


-- ================================= Đăng ký thông tin - Đối tác =================================
if object_id('USP_DANGKYTHONGTIN') is not null
	drop proc USP_DANGKYTHONGTIN
go
create proc USP_DANGKYTHONGTIN
	@MaDoiTac varchar(50),
	@SDT varchar(50),
	@LoaiAmThuc nvarchar(50),
	@SoLuongDonHangNgay int,
	@SoLuongChiNhanh int, 
	@DiaChi nvarchar(50),
	@TenQuan nvarchar(50),
	@NguoiDaiDien nvarchar(50),
	@Email varchar(50)
as
begin transaction
	begin try
		if (@MaDoiTac is null or @SDT is null or 
			@LoaiAmThuc is null or @SoLuongDonHangNgay is null or 
			@SoLuongChiNhanh is null or @DiaChi is null or 
			@TenQuan is null or @NguoiDaiDien is null or @Email is null)
		begin
			print N'Thông tin nhập không được rỗng'
			rollback transaction
			return 1
		end

		if exists (select * from DOITAC where MADOITAC = @MADOITAC)
		begin
			print N'Mã đối tác ' + @MADOITAC + N' đã tồn tại'
			rollback transaction
			return 1
		end

		insert into DOITAC values (@MaDoiTac, @SDT, @LoaiAmThuc, @SoLuongDonHangNgay, @SoLuongChiNhanh,
									@DiaChi, @TenQuan, @NguoiDaiDien, @Email, N'Chưa xác nhận')
	end try

	begin catch
		print N'lỗi hệ thống'
		rollback transaction
		return 1
	end catch

commit transaction
return 0
go

-- ================================= Quản lý cửa hàng - Đối tác =================================
if object_id('USP_QUANLICUAHANG') is not null
	drop proc USP_QUANLICUAHANG
go
-- 0 - thanh cong
-- 1 - that bai
create proc USP_QUANLICUAHANG
	@MADOITAC varchar(50),
	@MACUAHANG varchar(50),
	@TENQUAN nvarchar(50), 
	@GIOMOCUA time,
	@GIODONGCUA time,
	@TINHTRANG nvarchar(50)
as
set transaction isolation level REPEATABLE READ
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
		update CUAHANG set TENQUAN = @TENQUAN, GIOMOCUA = @GIOMOCUA, GIODONGCUA = @GIODONGCUA, TINHTRANG = @TINHTRANG where MADOITAC = @MADOITAC and MACUAHANG = @MACUAHANG

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

-- ======================================== Xóa cửa hàng ================================
if object_id('USP_XOACUAHANG') is not null
	drop proc USP_XOACUAHANG
go
-- 0 - thanh cong
-- 1 - that bai
create proc USP_XOACUAHANG
	@MaDoiTac varchar(50),
	@MaCuaHang varchar(50)
as
set transaction isolation level SERIALIZABLE
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
			print N'Cửa hàng cần xóa không tồn tại'
			rollback transaction
			return 1
		end
		
		delete from CUAHANG where MADOITAC = @MaDoiTac and MACUAHANG = @MaCuaHang

	end try

	begin catch
		print N'lỗi hệ thống'
		rollback transaction
		return 1
	end catch
commit transaction
return 0
go

-- ================================= Thêm món ăn - đối tác ============================
if object_id('USP_THEMMONAN') is not null
	drop proc USP_THEMMONAN
go
-- 0 - thanh cong
-- 1 - that bai
create proc USP_THEMMONAN
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
	begin try
		if not exists (select * from DOITAC where MADOITAC = @MADOITAC)
		begin
			print N'Không tìm thấy đối tác với mã ' + @MADOITAC
			rollback transaction
			return 1
		end

		if not exists (select * from THUCDON where MATHUCDON = @THUCDON and NHAHANG = @MADOITAC)
		begin
			print N'Thực đơn không thuộc quản lý của đối tác ' + @MADOITAC
			rollback transaction
			return 1
		end

		if exists (select * from MONAN where MAMONAN = @MAMONAN and THUCDON = @THUCDON)
		begin
			print N'Mã món ăn đã tồn tại trong thực đơn ' + @THUCDON
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
		
		insert into MONAN values (@MAMONAN, @THUCDON, @TENMON, @MIEUTA, @GIA, @TINHTRANG, @TUYCHON, @TENTUYCHON, @SOLUONG)
	end try

	begin catch
		print N'Lỗi'
		rollback transaction
		return 1
	end catch

commit transaction
return 0
go

exec USP_THEMMONAN
@MADOITAC='DT001',
@THUCDON='TD001',
@MAMONAN='MA004',
@TENMON =N'Vãi kẹc',
@MIEUTA =N'DDCm java',
@GIA =500,
@TINHTRANG =N'Còn món',
@SOLUONG =100,
@TUYCHON ='TC002',
@TENTUYCHON = N'Ít ớt'

-- ================================= Quản lý thực đơn - Đối tác =================================
if object_id('USP_QUANLITHUCDON') is not null
	drop proc USP_QUANLITHUCDON
go
-- 0 - thanh cong
-- 1 - that bai
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
	begin try
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
		
		update MONAN set TENMON=@TENMON, MIEUTA=@MIEUTA, GIA=@GIA, TINHTRANG=@TINHTRANG, 
		TUYCHON=@TUYCHON, SOLUONG=@SOLUONG, TENTUYCHON=@TENTUYCHON where MAMONAN=@MAMONAN and THUCDON=@THUCDON

	end try

	begin catch
		print N'Lỗi'
		rollback transaction
		return 1
	end catch

commit transaction
return 0
go

-- ================================= Xóa món ăn ========================================
if object_id('USP_XOAMONAN') is not null
	drop proc USP_XOAMONAN
go
-- 0 - thanh cong
-- 1 - that bai
create proc USP_XOAMONAN
	@MADOITAC varchar(50),
	@THUCDON varchar(50),
	@MAMONAN varchar(50)
as
set tran isolation level SERIALIZABLE
begin transaction
	begin try
		if not exists (select * from DOITAC where MADOITAC = @MADOITAC)
		begin
			print N'Không tìm thấy đối tác với mã ' + @MADOITAC
			rollback transaction
			return 1
		end

		if not exists (select * from THUCDON where MATHUCDON = @THUCDON and NHAHANG = @MADOITAC)
		begin
			print N'Thực đơn không thuộc quản lý của đối tác ' + @MADOITAC
			rollback transaction
			return 1
		end

		if not exists (select * from MONAN where MAMONAN = @MAMONAN and THUCDON = @THUCDON)
		begin
			print N'Món ăn không tồn tại trong thực đơn ' + @THUCDON
			rollback transaction
			return 1
		end


		if exists (select * from CHITIETDONHANG where MAMONAN = @MAMONAN and DOITAC = @MADOITAC)
		begin
			print N'Không thể xóa món ăn vì đang có người đặt hàng.'
			rollback transaction
			return 1
		end

		delete from MONAN where THUCDON = @THUCDON and MAMONAN = @MAMONAN

	end try

	begin catch
		print N'Lỗi'
		rollback transaction
		return 1
	end catch

commit transaction
return 0
go

select * from MONAN
exec USP_XOAMONAN @MADOITAC='DT001', @THUCDON='TD001', @MAMONAN='MA004'

-- ================================= Quản lý đơn đặt hàng - Đối tác =================================
if object_id('USP_CAPNHATTRANGTHAI') is not null
	drop proc USP_CAPNHATTRANGTHAI
go
create proc USP_CAPNHATTRANGTHAI
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

		if not exists (select * from KHACHHANG KH
						where KH.MAKHACHHANG = @KhachHang)
		begin
			print N'Mã khách hàng không tồn tại'
			rollback transaction
			return 1
		end
		
		if not exists (select * from DOITAC DT
						where DT.MADOITAC = @DoiTac)
		begin
			print N'Mã đối tác không tồn tại'
			rollback transaction
			return 1
		end
		
		if not exists (select * from DONDATHANG DDH 
			where DDH.MADONDATHANG = @MaDon and DDH.DOITAC = @DoiTac and DDH.KHACHHANG = @KhachHang)
		begin
			print N'Mã đơn hàng không tồn tại'
			rollback transaction
			return 1
		end

		if (@TinhTrang not in (N'Chờ nhận', N'Đang chuẩn bị', N'Đã nhận đơn hàng'))
		begin
			print N'Tình trạng đơn đặt hàng là Chờ nhận, Đang chuẩn bị hoặc Đã nhận đơn hàng'
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
			and MADONDATHANG = @MaDon
	
commit transaction
return 0
go

-- ================================= Đặt hàng =================================
if object_id('USP_DATHANG') is not null
	drop proc USP_DATHANG
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
			print N'Số tiền phải lớn hơn 0 vnđ'
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
		insert into CHITIETDONHANG values (@MACHITIET, @MADONDATHANG, @MAKHACHHANG, @MADOITAC, @MONAN, @SOLUONG, 
											(select top 1 TENQUAN from CUAHANG where MADOITAC=@MADOITAC), 
											(select top 1 DIACHI from CUAHANG where MADOITAC=@MADOITAC))
	end try

	begin catch
		print N'lỗi hệ thống'

		rollback transaction
		return 1
	end catch
commit transaction
return 0
go


-- ================================= Tạo hợp đồng mới =================================
if object_id('USP_LAPHOPDONG') is not null
	drop proc USP_LAPHOPDONG
go
create proc USP_LAPHOPDONG
	@MaHopDong varchar(50),
	@TenNganHang nvarchar(50),
	@ChiNhanh nvarchar(50),
	@SoTaiKhoan varchar(50),
	@DiaChi nvarchar(50),
	@NguoiDaiDien nvarchar(50),
	@SoChiNhanh int,
	@MaSoThue nvarchar(50),
	@ThoiHan date,
	@PhiHoaHong float,
	@TinhTrang nvarchar(50),
	@DoiTac varchar(50) -- foreign key
as
begin transaction
	begin try
		
		if (@MaHopDong is null or @TenNganHang is null or @ChiNhanh is null or
			@SoTaiKhoan is null or @DiaChi is null or @NguoiDaiDien is null or
			@SoChiNhanh is null or @MaSoThue is null or @ThoiHan is null or
			@PhiHoaHong is null or @TinhTrang is null or @DoiTac is null)
		begin
			print N'Thông tin cung cấp rỗng'
			rollback transaction
			return 1
		end
		
		if exists (select * from HOPDONG where MAHOPDONG = @MaHopDong)
		begin
			print N'Mã hợp đồng đã tồn tại'
			rollback transaction
			return 1
		end

		if datediff(DAY, GETDATE(), @ThoiHan) < 1
		begin
			print N'Thời hạn tính từ lúc lập hợp đồng (thời điểm hiện tại) không hợp lệ'
			rollback transaction
			return 1
		end

		if not exists (select * from DOITAC where MADOITAC = @DoiTac)
		begin
			print N'Mã đối tác không tồn tại'
			rollback transaction
			return 1
		end

		if (@TinhTrang not in (N'Chưa xác nhận', N'Đã xác nhận'))
		begin
			print N'Tình trạng Hợp đồng là Chưa xác nhận hoặc Đã xác nhận'
			rollback transaction
			return 1
		end
		
	end try

	begin catch
		print N'lỗi hệ thống'
		rollback transaction
		return 1
	end catch

commit transaction
return 0
go


-- ================================= Đăng ký - Khách hàng =================================
if object_id('USP_DANGKYKHACHHANG') is not null
	drop proc USP_DANGKYKHACHHANG
go
create proc USP_DANGKYKHACHHANG
	@MaKhachHang varchar(50),
	@HoTen nvarchar(50),
	@SDT varchar(50),
	@DiaChi nvarchar(50),
	@Email varchar(50)
as
set transaction isolation level serializable
begin transaction
	begin try
		
		if (@MaKhachHang is null or @HoTen is null or @SDT is null or
			@DiaChi is null or @Email is null)
		begin
			print N'Thông tin cung cấp rỗng'
			rollback transaction
			return 1
		end

		if exists (select * from KHACHHANG where MAKHACHHANG = @MaKhachHang)
		begin
			print N'Mã khách hàng tồn tại'
			rollback transaction
			return 1
		end
		
		insert into KHACHHANG values (@MaKhachHang, @HoTen, @SDT, @DiaChi, @Email)

	end try

	begin catch
		print N'lỗi hệ thống'
		rollback transaction
		return 1
	end catch

commit transaction
return 0
go

-- ================================= hủy đơn - Khách hàng =================================
if object_id('USP_HUYDONHANG') is not null
	drop proc USP_HUYDONHANG
go
create proc USP_HUYDONHANG
	@KhachHang varchar(50),
	@DoiTac varchar(50),
	@MaDon varchar(50)
as
begin transaction
	begin try
		if (@KhachHang is null or @DoiTac is null or @MaDon is null)
		begin
			print N'Thông tin cung cấp rỗng'
			rollback transaction
			return 1
		end

		if not exists (select * from DONDATHANG 
						where KHACHHANG = @KhachHang and DOITAC = @DoiTac and MADONDATHANG = @MaDon)
		begin
			print N'Đơn hàng không tồn tại'
			rollback transaction
			return 1
		end

		if N'Chờ nhận' not in (select TINHTRANG from DONDATHANG 
								where KHACHHANG = @KhachHang and DOITAC = @DoiTac and MADONDATHANG = @MaDon)
		begin
			print N'Đơn hàng đã không còn có thể hủy'
			rollback transaction
			return 1
		end
		
		delete from CHITIETDONHANG where MADONDATHANG = @MaDon
		delete from DONDATHANG where KHACHHANG = @KhachHang and DOITAC = @DoiTac and MADONDATHANG = @MaDon

	end try

	begin catch
		print N'lỗi hệ thống'
		rollback transaction
		return 1
	end catch

commit transaction
return 0
go

-- ============================  ============================
if object_id('USP_DANGKYTAIXE') is not null
	drop proc USP_DANGKYTAIXE
go
create proc USP_DANGKYTAIXE
	@MaTaiXe varchar(50),
	@HoTen nvarchar(50),
	@SDT varchar(50),
	@DiaChi nvarchar(200),
	@BienSoXe varchar(50),
	@KhuVuc nvarchar(50),
	@EMAIL varchar(50),
	@SoTaiKhoan varchar(50),
	@TenNganHang nvarchar(50)
as
begin transaction
	begin try
		
		if (@MaTaiXe is null or @HoTen is null or @SDT is null or 
			@DiaChi is null or @BienSoXe is null or @KhuVuc is null or 
			@EMAIL is null or @SoTaiKhoan is null or @TenNganHang is null)
		begin
			print N'Thông tin cung cấp rỗng'
			rollback transaction
			return 1
		end

		if exists (select * from TAIXE where MATAIXE = @MaTaiXe)
		begin
			print N'Mã tài xế tồn tại'
			rollback transaction
			return 1
		end
		
		insert into TAIXE values (@MaTaiXe, @HoTen, @SDT, @DiaChi, @BienSoXe, 
										@KhuVuc, @EMAIL, @SoTaiKhoan, @TenNganHang)

	end try

	begin catch
		print N'lỗi hệ thống'
		rollback transaction
		return 1
	end catch

commit transaction
return 0
go

-- ==========================================================================


