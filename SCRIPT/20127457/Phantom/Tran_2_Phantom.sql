-- note: run the whole file
use thuongmaidientu 
go

-- exec proc
declare @rt int
exec @rt = USP_THEMMONAN
@MADOITAC='DT001',
@THUCDON='TD001',
@MAMONAN='MA003',
@TENMON =N'Cơm chiên cá mập',
@MIEUTA =N'Thơm ngon',
@GIA =500,
@TINHTRANG =N'Còn món',
@SOLUONG =100,
@TUYCHON ='TC002',
@TENTUYCHON = N'Ít ớt'


if @rt = 0
	print N'Thêm món ăn thành công'
else 
	print N'Thêm món ăn thất bại'

select * from monan
