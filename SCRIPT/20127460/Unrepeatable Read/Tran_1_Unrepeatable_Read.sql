-- note: run the whole file
use thuongmaidientu 
go

-- must be run before execute proc
delete from chitietdonhang where madondathang='DDH006'
delete from dondathang where madondathang='DDH006'
update monan set soluong = 80 where mamonan = 'MA001' and thucdon='TD001'


-- exec proc
declare @rt int
exec @rt = USP_DATHANG @MADONDATHANG='DDH006', @MAKHACHHANG='KH001', @MADOITAC='DT001', @THANHTIEN=2000, @MACHITIET='CT008', @THUCDON='TD001', @MONAN='MA001', @SOLUONG=10
if @rt = 0
	print N'Đặt hàng thành công'
else 
	print N'Đặt hàng thât bại'

select * from monan
