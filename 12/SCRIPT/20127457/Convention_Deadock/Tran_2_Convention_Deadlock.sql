--Giao tác 2
use thuongmaidientu
go

-- Đối tác DT001 cập nhật thông tin cửa hàng CH001
declare @RT int
exec @RT = USP_CAPNHATCUAHANG 'DT001', 'CH001', N'HAIDILO', 1, N'89 phan xích long bình thạnh tphcm', '08:00:00', '17:00:00', N'Đang mở'

if @RT = 1
	print N'Cập nhật thất bại'
else
	print N'Cập nhật thành công'

--select * from DONDATHANG