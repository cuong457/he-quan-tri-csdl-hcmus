--Giao tác 1
use thuongmaidientu
go

-- Đối tác DT001 cập nhật đơn hàng CT001 của khách hàng KH001
declare @RT int
exec @RT = USP_CAPNHATTRANGTHAI_DT 'KH001', 'DT001', 'CT001', N'Chờ xác nhận'

if @RT = 1
	print N'Cập nhật thất bại'
else
	print N'Cập nhật thành công'

--select * from DONDATHANG