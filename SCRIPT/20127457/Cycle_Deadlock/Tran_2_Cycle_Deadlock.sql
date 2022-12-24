--Giao tác 2
use thuongmaidientu
go

-- Tài xế cập nhật đơn hàng cập nhật đơn hàng CT001 của khách hàng KH001 với Đối tác DT001
declare @RT int
exec @RT = USP_CAPNHATTRANGTHAI_TX 'KH001', 'DT001', 'CT001', N'Đang vận chuyển'

if @RT = 1
	print N'Cập nhật thất bại'
else
	print N'Cập nhật thành công'

--select * from DONDATHANG