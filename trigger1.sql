drop table s_auto;
create table s_auto as
select * from szerelo.sz_auto;

create or replace trigger tr_s_auto2 
before insert or update or delete on s_auto
begin
 dopl('A m?dos?t?s el?tt lefutott');
end;
/

select *
from s_auto;

delete s_auto
where szin='fekete';

create or replace trigger tr_s_auto1 
before insert or update or delete on s_auto
for each row
begin
dopl('?j:'||:new.rendszam);
dopl('old:'||:old.rendszam);
end;
/

select *
from s_auto;

update s_auto
set elso_vasarlasi_ar=elso_vasarlasi_ar+1
where szin='k?k';

insert into s_auto(azon, rendszam)
values (1000, 'ABS123');

drop table naplo;
create table naplo
(s varchar2(1000));

create or replace trigger s_tr_naplo1
before update or delete on naplo
begin
raise_application_error(-20001, 'A t?bl?b?l nem lehet t?r?lni');
end;

delete naplo;

create or replace trigger tr_s_auto3 
before insert or update or delete on s_auto
for each row
begin
insert into naplo (s) values ('?j:'||:new.rendszam||' old:'||:old.rendszam);
end;
/


delete s_auto
where szin='k?k';

select *
from naplo;

commit;

create table szamok
(sz number(5));

create or replace trigger tr_szamok
before insert or update of sz on szamok
for each row
begin
:new.sz:=:new.sz*2;
end;

insert into szamok values (10);
select * from szamok;

update szamok
set sz=5;

select * from szamok;


create or replace trigger tr_szamok2
before insert or update or delete on szamok

begin
  if inserting
  then dopl('insert');
  elsif updating
  then dopl('update');
  elsif deleting
  then dopl('delete');
  end if;
end;
/

insert into szamok values (20);
update szamok set sz=sz+1 where sz=40;
update szamok set sz=sz+1 where sz=1000;

--403	?rjon triggert, amely akkor indul el, amikor az aut?_tulajdonosa t?bl?ba 
--?j sort vesz?nk fel. 
--A trigger egy napl? t?bl?ba ?rja a tulajdonos nev?t, az aut? rendsz?m?t ?s a besz?r?s idej?t.
drop table auto_tulajdonosa;
create table auto_tulajdonosa as
select *
from szerelo.sz_auto_tulajdonosa;

create table naplo2
(tulaj_nev varchar2(30), 
rendszam varchar2(20),
beszuras_ideje date);

create or replace trigger tr_au_tu
after insert on auto_tulajdonosa
for each row
declare 
v_tu_nev szerelo.sz_tulajdonos.nev%type;
v_rsz szerelo.sz_auto.rendszam%type;
begin
select nev into v_tu_nev
from szerelo.sz_tulajdonos
where azon=:new.tulaj_azon;

select rendszam into v_rsz
from szerelo.sz_auto
where azon=:new.auto_azon;

insert into naplo2 (tulaj_nev,rendszam,beszuras_ideje) values (v_tu_nev, v_rsz, sysdate);
end;
/
--404	Sz?rjon be az aut? t?bl?ba 3 sort. 
insert into auto_tulajdonosa (auto_azon, vasarlas_ideje, tulaj_azon)
values (103, sysdate, 515);
commit;
select * from naplo2;
--407	?rjon triggert, amely nem enged olyan szerel?st felvinni vagy olyanra m?dos?tani, 
--ahol a szerel?s munkav?gz?s?nek az ?ra t?bb, mint az aut? els? beszerz?si ?r?nak a 10%-a. 
--Dobjon kiv?telt a trigger ezekben az esetekben.
--408	Pr?b?lja ki az el?z? triggert.
drop table szereles;
create table szereles as
select * from szerelo.sz_szereles;

create or replace trigger tr_sz
before insert or update on szereles
for each row
declare 
v szerelo.sz_auto.elso_vasarlasi_ar%type;
begin
select elso_vasarlasi_ar
into v
from szerelo.sz_auto
where azon=:new.auto_azon;

if :new.munkavegzes_ara>v*0.1 then raise_application_error(-20002, 'Sok munkad?j'); end if;
end;

INSERT INTO szereles (auto_azon,muhely_azon,szereles_kezdete,munkavegzes_ara)
VALUES (103, 101, sysdate, 1000000);

--409	Hozzon l?tre t?bl?t a k?vetkez? oszlopokkal: rendszam, tipus, marka.
--410	?rjon triggert, amely akkor indul el, amikor az el?z? feladat t?bl?j?ba besz?rnak, 
--vagy m?dos?tj?k azt. A trigger a m?rk?t az adatb?zisban t?rolt t?pus ?s m?rka t?bl?k 
--alapj?n t?ltse ki. ?s ne vegye figyelembe, hogy a felhaszn?l? hogyan szerette volna 
--kit?lteni az oszlopot.
--411	Pr?b?lja ki az el?z? feladat trigger?t
create table au
(rendszam varchar2(10), 
tipus varchar2(20),
marka varchar2(20));

create or replace trigger tr_au10
before insert or update on au
for each row
begin
select marka
into :new.marka
from szerelo.sz_autotipus
where megnevezes=:new.tipus;
end;
/

insert into au (rendszam ,tipus,marka ) values (103,'Corsa','Toyota');
select * from au;
commit;

drop table au;

drop table s_auto;
create table s_auto as
select * from szerelo.sz_auto
order by tipus_azon;

create view v_au as
select azon, szin, rendszam
from s_auto
where tipus_azon=7;

select *
from v_au;

insert into v_au (azon, szin, rendszam)
values (1, 'piros','ABS123');

select * from s_auto where azon=1;

create or replace trigger tr_v_au
INSTEAD of insert on v_au
begin
insert into s_auto (azon, szin, rendszam, tipus_azon)
values (:new.azon, :new.szin, :new.rendszam, 7);
end;
/

insert into v_au (azon, szin, rendszam)
values (2, 'piros','ABS124');
select *
from v_au;
select * from s_auto where azon=2;

--412	Hozzon l?tre n?zetet, amelyben az egyes aut?k (auto_azon) 
--utols? fel?rt?kel?s?nek ideje ?s ?ra szerepel. 
--413	Hozzon l?tre triggert, amely az el?z? feladat n?zet?re val? besz?r?s helyett fut le. 
--Az ?rt?keket a m?g?ttes autofelertekeles t?bl?ba sz?rja be, de csak akkor, 
--ha a d?tum nagyobb, mint az adott aut?hoz tartoz? ?sszes d?tum.
--414	Pr?b?lja ki az el?z? feladat trigger?t.
create table autfe as 
select * from szerelo.sz_autofelertekeles;

create view v_afe as
select *
from autfe
where (auto_azon, datum) in (select auto_azon, max(datum)
                             from autfe
                             group by auto_azon);
                             
create or replace trigger tr_afe
instead of insert on v_afe
declare 
 v autfe.datum%type;
begin
select max(datum)
into v
from autfe
where auto_azon=:new.auto_azon;
if v<:new.datum
  then INSERT INTO autfe (    auto_azon,    datum,    ertek) 
       VALUES (:new.auto_azon,    :new.datum,    :new.ertek  );
  else dopl('Van k?s?bbi d?tum');
end if;
end;

INSERT INTO v_afe(    auto_azon,    datum,    ertek) 
       VALUES (104, sysdate, 2000000);
       
       select *
       from autfe
       where auto_azon=104;
