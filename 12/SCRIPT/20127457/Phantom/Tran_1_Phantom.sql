-- note: run the whole file
use thuongmaidientu 
go

-- must be run before execute proc
delete from chitietdonhang where madondathang='DDH006'
delete from dondathang where madondathang='DDH006'

delete from MONAN where MAMONAN='MA003' and THUCDON='TD001'


-- exec proc
declare @rt int
exec @rt = USP_DATHANG @MADONDATHANG='DDH006', @MAKHACHHANG='KH001', @MADOITAC='DT001', 
		@THANHTIEN=2000, @MACHITIET='CT006', @THUCDON='TD001', @MONAN='MA003', @SOLUONG=10
if @rt = 0
	print N'Đặt hàng thành công'
else 
	print N'Đặt hàng thât bại'
