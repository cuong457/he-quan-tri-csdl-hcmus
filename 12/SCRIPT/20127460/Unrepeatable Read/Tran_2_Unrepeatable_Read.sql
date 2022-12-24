-- note: run the whole file
use thuongmaidientu
go

DECLARE @rt int
exec @rt = USP_QUANLITHUCDON @MADOITAC='DT001', @THUCDON='TD001', @MAMONAN='MA001', @TENMON=N'Phở ngon', @MIEUTA=N'Phở rất ngon', @GIA='200', @TINHTRANG=N'Còn món', @SOLUONG=9, @TUYCHON='TC002', @TENTUYCHON=N'Ít ớt'

if @rt = 0
	print N'Cập nhật thông tin thực đơn thành công'
else 
	print N'Cập nhật thông tin thực đơn thât bại'

select * from thucdon
select * from monan