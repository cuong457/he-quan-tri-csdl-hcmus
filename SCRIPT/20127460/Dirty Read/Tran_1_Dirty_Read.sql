-- note: run the whole file
use thuongmaidientu
go

DECLARE @rt int
exec @rt = USP_QUANLICUAHANG @MADOITAC='DT001', @MACUAHANG='CH001', @TENQUAN=N'haidilao', @GIOMOCUA='08:00:00', @GIODONGCUA='17:00:00', @TINHTRANG=N'Đang mở'

if @rt = 0
	print N'Cập nhật thông tin cửa hàng thành công'
else 
	print N'Cập nhật thông tin cửa hàng thât bại'

select * from cuahang