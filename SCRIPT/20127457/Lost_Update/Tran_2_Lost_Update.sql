-- note: run the whole file
use thuongmaidientu 
go

-- must be run before execute proc

-- exec proc
declare @rt int
exec @rt = USP_DATHANG_1 @MADONDATHANG='DDH008', @MAKHACHHANG='KH002', @MADOITAC='DT001', 
		@THANHTIEN=2000, @MACHITIET='CT008', @THUCDON='TD001', @MONAN='MA001', @SOLUONG=10
if @rt = 0
	print N'Đặt hàng thành công'
else 
	print N'Đặt hàng thât bại'

select * from MONAN