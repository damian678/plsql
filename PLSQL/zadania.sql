set serveroutput on;

--Funkcje i procedury
create table studenci(
id_studenta number primary key,
imie varchar2(50),
nazwisko varchar2(50));

create sequence seq_id_studenta;

--1
create or replace procedure nowy_student
(p_imie varchar2, p_nazwisko varchar2)
as
begin
insert into studenci values (seq_id_studenta.nextval,p_imie,p_nazwisko);
end;

begin
nowy_student('Jan','Kowalski');
end;


select * from studenci;

--2
create or replace procedure zmiana_danych
(p_id_studenta number,p_imie varchar2,p_nazwisko varchar2)
as
begin
update studenci set imie=p_imie,nazwisko=p_nazwisko where id_studenta=p_id_studenta;
end;

begin
zmiana_danych(1,'Maria','Nowak');
end;

select * from studenci;

--3
create or replace procedure usun_studenta
(p_id_studenta in studenci.id_studenta%type)
as
begin
delete from studenci where id_studenta=p_id_studenta;
end;

begin
usun_studenta(1);
end;

select * from studenci;

--4
create or replace function imie_nazwisko
(p_id_studenta number)
return varchar2 as
z_danestudenta varchar2(100);
begin
select imie ||' '|| nazwisko into z_danestudenta
from studenci
where id_studenta=p_id_studenta;
return z_danestudenta;
end;

begin 
dbms_output.put_line(imie_nazwisko(2)); --aby włączyć: View -> Dbms Output
end;

select imie_nazwisko(2) from dual;


--5
create or replace function rekord
(p_id_studenta number)
return studenci%rowtype as wiersz studenci%rowtype;
begin 
select * into wiersz from studenci
where id_studenta = p_id_studenta;
return wiersz;
end rekord;

declare 
rcd studenci%rowtype;
begin 
rcd:=rekord(2);
dbms_output.put_line(rcd.id_studenta|| ' ' ||rcd.imie|| ' ' ||rcd.nazwisko);
end;


--6
create table przedmioty(
id_przedmiotu number primary key,
nazwa_przedmiotu varchar2(20));

create sequence seq_id_przedmiotu;

--Procedura dodająca przedmiot
create or replace procedure nowy_przedmiot
(p_nazwa_przedmiotu varchar2)
as
begin
insert into przedmioty values (seq_id_przedmiotu.nextval,p_nazwa_przedmiotu);
end;

begin
nowy_przedmiot('Algebra');
end;

select * from przedmioty;

--Procedura zmieniająca nazwę przedmiotu
create or replace procedure zmiana_nazwy_przedmiotu
(p_id_przedmiotu number, p_nazwa_przedmiotu varchar2)
as
begin
update przedmioty set nazwa_przedmiotu=p_nazwa_przedmiotu 
where id_przedmiotu=p_id_przedmiotu;
end;

begin
zmiana_nazwy_przedmiotu(1,'Analiza');
end;

select * from przedmioty;

--Procedura usuwająca przedmiot
create or replace procedure usun_przedmiot
(p_id_przedmiotu in studenci.id_studenta%type)
as
begin
delete from przedmioty where id_przedmiotu=p_id_przedmiotu;
end;

begin
usun_przedmiot(1);
end;

select * from przedmioty;

--Funkcja zwracająca łańcuch z id i nazwą przedmiotu
create or replace function zwroc_lancuch
(p_id_przedmiotu number)
return varchar2 as
z_daneprzedmiotu varchar2(100);
begin
select  id_przedmiotu ||' '|| nazwa_przedmiotu into z_daneprzedmiotu
from przedmioty
where id_przedmiotu=p_id_przedmiotu;
return z_daneprzedmiotu;
end;

begin 
dbms_output.put_line(zwroc_lancuch(2)); --aby włączyć: View -> Dbms Output
end;

select zwroc_lancuch(2) from dual;

--Funkcja zwracająca rekord z danymi
create or replace function rekord_przedmioty
(p_id_przedmiotu number)
return przedmioty%rowtype as wiersz przedmioty%rowtype;
begin 
select * into wiersz from przedmioty
where id_przedmiotu = p_id_przedmiotu;
return wiersz;
end;

declare 
rcd przedmioty%rowtype;
begin 
rcd:=rekord_przedmioty(2);
dbms_output.put_line(rcd.id_przedmiotu|| ' ' ||rcd.nazwa_przedmiotu);
end;

--Wyzwalacze

--7
create or replace trigger student_autonumerowanie
before insert on studenci
for each row
when (new.id_studenta is null)
begin
select seq_id_studenta.nextval into
:new.id_studenta from dual;
end;

insert into studenci values (null,'Adam','Kowal');

select * from studenci;

--8
--Tabele
create table oceny(
id_oceny number,
przedmiot varchar2(30),
rodzaj_zaliczenia varchar2(40),
ocena number(2,1)check(ocena between 2 and 5),
primary key(id_oceny));

create table ocena_log(
id_zmiany number,
user_name varchar2(50),
id_oceny number,
stara_ocena number(2,1),
nowa_ocena number(2,1),
data_zmiany date,
primary key(id_zmiany));


--Sekwencje
create sequence seq_oceny;
create sequence seq_ocena_log;

insert into oceny values (seq_oceny.nextval,'Bazy danych','projekt',4.5);
insert into oceny values (seq_oceny.nextval,'Algebra','kolokwium',4);

--Trigger
create or replace trigger zmiana_oceny
before update of ocena on oceny
for each row
begin
insert into ocena_log
values(seq_ocena_log.nextval,user,:new.id_oceny,:old.ocena,:new.ocena,sysdate);
end;


update oceny set ocena=3 where id_oceny=1;
update oceny set ocena=3.5 where id_oceny=2;


select * from oceny;
select * from ocena_log;

--9
--Trigger
create or replace trigger usuwanie_wierszy
before delete on oceny
for each row
begin
insert into ocena_log
values(seq_ocena_log.nextval,user,:old.id_oceny,:old.ocena,:new.ocena,sysdate);
end;

delete from oceny where id_oceny=1;

select * from oceny;
select * from ocena_log;

--10
--Trigger
create or replace trigger rejestr_ocen
before delete or update or insert on oceny
for each row
begin
insert into ocena_log
values(seq_ocena_log.nextval,user,:new.id_oceny,:old.ocena,:new.ocena,sysdate);
end;

insert into oceny values (seq_oceny.nextval,'Topologia','egzamin',2);
delete from oceny where id_oceny=2;
update oceny set ocena=3 where id_oceny=2;

select * from oceny;
select * from ocena_log;

--za pomocą predykatów
alter table ocena_log add uwaga varchar2(30);

--Trigger
create or replace trigger rejestr_ocen_predykaty
before delete or update or insert on oceny
for each row
begin
if inserting then
insert into ocena_log
values(seq_ocena_log.nextval,user,:new.id_oceny,:old.ocena,:new.ocena,sysdate,'dodano ocenę');
elsif updating then
insert into ocena_log
values(seq_ocena_log.nextval,user,:new.id_oceny,:old.ocena,:new.ocena,sysdate,'zmieniono ocenę');
else 
insert into ocena_log
values(seq_ocena_log.nextval,user,:old.id_oceny,:old.ocena,:new.ocena,sysdate,'usunięto ocenę');
end if;
end;

insert into oceny values (seq_oceny.nextval,'Geometria','projekt',5);
delete from oceny where id_oceny=5;
update oceny set ocena=4 where id_oceny=4;

select * from oceny;
select * from ocena_log;


create or replace function pole1
(bok number)
return number as wynik number;
begin
wynik:=bok*bok;
return wynik;
end;

begin 
dbms_output.put_line(pole1(2));
end;

