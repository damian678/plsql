create table czytelnicy(id_czytelnika number primary key, imie varchar2(50), nazwisko varchar2(50));
create table ksiazki(sygnatura number primary key, autor varchar2(50), 
tytul varchar2(500), id_czytelnika number references czytelnicy);

insert into czytelnicy  values (1, 'twoje-imiê', 'twoje-nazwisko');
insert into ksiazki values (1, 'zaproponuj-autora', 'zaproponuj-tytu³', 1);

grant select on czytelnicy to mat17uzfina4;--nadaje uprawnienia u¿ytkownikowi

select * from mat17uzfina4.czytelnicy;
insert into  mat17uzfina4.czytelnicy values(2, 'Jan', 'Kowalski');

select * from user_tab_privs;

revoke select on czytelnicy from mat17uzfina4;--odbiera uprawnienia u¿ytkownikowi
select * from mat17uzfina4;
--6
grant select, insert on ksiazki to mat17uzfina4;-- nadaje uprawnienia u¿ytkownikow z tabeli ksi¹¿ki 
--do wstawiania wierszy do tej tabeli
select * from mat17uzfina4.ksiazki;
insert into  mat17uzfina4.ksiazki values(2, 'Celko', 'SQL', null);
select * from mat17uzfina4.ksiazki;
SELECT * FROM ksiazki;
revoke select,insert on ksiazki from  mat17uzfina4;--odbiera uprawnienia u¿ytkownikow z tabeli ksi¹¿ki 
--do wstawiania wierszy do tej tabeli
--8
grant select,insert,update,delete on czytelnicy to mat17uzfina4;
select * from mat17uzfina4.czytelnicy;

insert into mat17uzfina4.czytelnicy values (2,'Jan','Kowalski');
update mat17uzfina4.czytelnicy set imie='Adam' where id_czytelnika=2;
delete from mat17uzfina4.czytelnicy where id_czytelnika=2;
--10
create table ksiazki2(sygnatura number primary key, autor varchar2(50), tytul varchar2(500), 
id_czytelnika references 
mat17uzfina4.czytelnicy);--nie posiada uprawnieñ dla kluczy obcych

grant references on czytelnicy to mat17uzfina4;
create table ksiazki2(sygnatura number primary key, autor varchar2(50), tytul varchar2(500), 
id_czytelnika references 
mat17uzfina4.czytelnicy);--teraz siê udalo
--12
grant update (autor,tytul),insert(sygnatura,autor,tytul),select on ksiazki to mat17uzfina4;--uprawnienie do modyfikacji kolumn

insert into  mat17uzfina4.ksiazki values(11, 'Hellman', 'AndroidC', null);

insert into mat17uzfina4.ksiazki (sygnatura,autor,tytul) values
(11,'Hellman','Android');
select * from mat17uzfina4.ksiazki;
update mat17uzfina4.ksiazki set id_czytelnika=null where sygnatura=1;--niewystarczajace uprawnienia

update mat17uzfina4.ksiazki set tytul=upper(tytul) where sygnatura=1;
--13
grant alter on ksiazki to mat17uzfina4;--nadaje uprawnienia do modyfikacji tabel ksiazki
alter table mat17uzfina4.ksiazki add(rok number(4));
select * from mat17uzfina4.ksiazki;
select * from ksiazki;
--14
grant select, insert, delete on ksiazki to mat17uzfina4 with grant option;
--grant select,insert, delete on mat17uzfina4.ksiazki to mat17uzfina? with grant option;

--16
create table lista_studentow (
id_studenta number,
imie varchar2(20),
nazwisko varchar2(20),
plec varchar(1) check (plec='m' or plec='k'));

create sequence sequence_id_studenta
start with 1;
--drop table lista_studentow;
--drop sequence sequence_id_studenta;
--17
grant select, insert, update, delete on lista_studentow to public;
grant select on sequence_id_studenta to public;

--18
insert into lista_studentow values(sequence_id_studenta.nextval,'Damian','Bilski','m');
select distinct imie,nazwisko  from lista_studentow order by nazwisko;
commit;
--19 
create view studentki as
select * from lista_studentow where plec='k';
select distinct imie,nazwisko from studentki;
create view studenci as
select * from lista_studentow where plec='m';
select distinct imie,nazwisko from studenci;

grant select on studentki to mat17uzfina4,mat17uzfina12,mat17uzfina3;