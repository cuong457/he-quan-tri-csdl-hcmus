--Giao tác 1
use thuongmaidientu
go

-- Admin cập nhật thông tin cửa hàng CH001 của đối tác DT001
declare @RT int
exec @RT = USP_CAPNHATCUAHANG 'DT001', 'CH001', N'HAIDILO', 1, N'87 phan xích long bình thạnh tphcm', '08:00:00', '17:00:00', N'Đang mở'

if @RT = 1
	print N'Cập nhật thất bại'
else
	print N'Cập nhật thành công'

--select * from CUAHANG