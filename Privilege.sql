﻿
--Phân công
--20127457 - Phạm Nguyễn Cao Cường

--====================== Tạo LOGIN ======================--

-- Tạo login cho ĐỐI TÁC
use master;
go
create login DT001
with password = '123',
default_database = thuongmaidientu;

create login DT002
with password = '123',
default_database = thuongmaidientu;

create login DT003
with password = '123',
default_database = thuongmaidientu;

create login DT004
with password = '123',
default_database = thuongmaidientu;

create login DT005
with password = '123',
default_database = thuongmaidientu;

--==========================================

-- Tạo login cho KHÁCH HÀNG
use master;
go
create login KH001
with password = '123',
default_database = thuongmaidientu;

create login KH002
with password = '123',
default_database = thuongmaidientu;

create login KH003
with password = '123',
default_database = thuongmaidientu;

create login KH004
with password = '123',
default_database = thuongmaidientu;

create login KH005
with password = '123',
default_database = thuongmaidientu;

--==========================================

-- Tạo login cho TÀI XẾ
use master;
go
create login TX001
with password = '123',
default_database = thuongmaidientu;

create login TX002
with password = '123',
default_database = thuongmaidientu;

create login TX003
with password = '123',
default_database = thuongmaidientu;

create login TX004
with password = '123',
default_database = thuongmaidientu;

--==========================================

-- Tạo login cho NHÂN VIÊN
use master;
go
create login NV001
with password = '123',
default_database = thuongmaidientu;

create login NV002
with password = '123',
default_database = thuongmaidientu;

create login NV003
with password = '123',
default_database = thuongmaidientu;

create login NV004
with password = '123',
default_database = thuongmaidientu;

--==========================================

-- Tạo login cho QUẢN TRỊ
use master;
go
create login QT001
with password = '123',
default_database = thuongmaidientu;

create login QT002
with password = '123',
default_database = thuongmaidientu;

create login QT003
with password = '123',
default_database = thuongmaidientu;

create login QT004
with password = '123',
default_database = thuongmaidientu;


--====================== TẠO USER ======================-- 

use thuongmaidientu
go
create user DoiTac001 for login DT001
create user DoiTac002 for login DT002
create user DoiTac003 for login DT003
create user DoiTac004 for login DT004
create user DoiTac005 for login DT005
go

use thuongmaidientu
go
create user KhachHang001 for login KH001
create user KhachHang002 for login KH002
create user KhachHang003 for login KH003
create user KhachHang004 for login KH004
create user KhachHang005 for login KH005
go

use thuongmaidientu
go
create user TaiXe001 for login TX001
create user TaiXe002 for login TX002
create user TaiXe003 for login TX003
create user TaiXe004 for login TX004
go

use thuongmaidientu
go
create user NhanVien001 for login NV001
create user NhanVien002 for login NV002
create user NhanVien003 for login NV003
create user NhanVien004 for login NV004
go

use thuongmaidientu
go
create user QuanTri001 for login QT001
create user QuanTri002 for login QT002
create user QuanTri003 for login QT003
create user QuanTri004 for login QT004
go

--====================== TẠO ROLE ======================--

use thuongmaidientu
go
create role DoiTac
create role KhachHang
create role TaiXe
create role NhanVien
create role QuanTri
go

use thuongmaidientu
go
alter role DoiTac add member DoiTac001
alter role DoiTac add member DoiTac002
alter role DoiTac add member DoiTac003
alter role DoiTac add member DoiTac004
alter role DoiTac add member DoiTac005
go

use thuongmaidientu
go
alter role KhachHang add member KhachHang001
alter role KhachHang add member KhachHang002
alter role KhachHang add member KhachHang003
alter role KhachHang add member KhachHang004
alter role KhachHang add member KhachHang005
go

use thuongmaidientu
go
alter role QuanTri add member QuanTri001
alter role QuanTri add member QuanTri002
alter role QuanTri add member QuanTri003
alter role QuanTri add member QuanTri004
go

--====================== TẠO VIEW ======================--
--Đối tác 1
use thuongmaidientu
go
--create view VIEW_DOITAC as
--select * from DOITAC
--go

grant select on OBJECT::DOITAC to DoiTac

use thuongmaidientu
go
create view VIEW_DONDATHANG as
select MADONDATHANG, DOITAC, TINHTRANG, THANHTIEN from DONDATHANG
go
grant select on OBJECT::VIEW_DONDATHANG to KhachHang


--=========================================================
-- Admin
use thuongmaidientu
go
grant select, update on OBJECT::DOITAC to QuanTri with grant option
grant select, update on OBJECT::KHACHHANG to QuanTri with grant option
grant select, update on OBJECT::TAIXE to QuanTri with grant option
grant select, insert, delete, update on OBJECT::NHANVIEN to QuanTri with grant option
grant select, insert, delete, update on OBJECT::QUANTRI to QuanTri with grant option
go

-- ===================== XÓA ===================
--use master
--go
--exec sp_droplogin DT001
--exec sp_droplogin DT002
--exec sp_droplogin DT003
--exec sp_droplogin DT004
--exec sp_droplogin DT005

--exec sp_droplogin KH001
--exec sp_droplogin KH002
--exec sp_droplogin KH003
--exec sp_droplogin KH004
--exec sp_droplogin KH005

--exec sp_droplogin TX001
--exec sp_droplogin TX002
--exec sp_droplogin TX003
--exec sp_droplogin TX004

--exec sp_droplogin NV001
--exec sp_droplogin NV002
--exec sp_droplogin NV003
--exec sp_droplogin NV004

--exec sp_droplogin QT001
--exec sp_droplogin QT002
--exec sp_droplogin QT003
--exec sp_droplogin QT004
--go

--use thuongmaidientu
--go
--drop user DoiTac001
--drop user DoiTac002
--drop user DoiTac003
--drop user DoiTac004
--drop user DoiTac005
--go
--drop user KhachHang001
--drop user KhachHang002
--drop user KhachHang003
--drop user KhachHang004
--drop user KhachHang005
--go
--drop user TaiXe001
--drop user TaiXe002
--drop user TaiXe003
--drop user TaiXe004
--go
--drop user NhanVien001
--drop user NhanVien002
--drop user NhanVien003
--drop user NhanVien004
--go
--drop user QuanTri001
--drop user QuanTri002
--drop user QuanTri003
--drop user QuanTri004
--go
--use thuongmaidientu
--go
--drop role DoiTac
--drop role KhachHang
--drop role TaiXe
--drop role NhanVien
--drop role QuanTri