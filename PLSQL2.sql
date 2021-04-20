declare
  function f_pow(p_a number) return number is
     v number(10);
    begin
    v:=p_a*p_a;
    return v;
    end;
    
  procedure proc_kiir(p_s varchar2) is
    begin
    dbms_output.put_line(p_s);
    end;

begin
proc_kiir(f_pow(5));
end;


create or replace procedure dopl(p_s varchar2) is
begin
dbms_output.put_line(p_s);
end;

begin
dopl('Almafa');
end;

create or replace function f_szin_auto_db(p_szin szerelo.sz_auto.szin%type) return number is
  v number(5);
begin

select count(*)
into v
from szerelo.sz_auto
where szin=p_szin;

return v;
end;

begin
dopl(f_szin_auto_db('piros'));
end;

declare
 v number(5);
begin
v:=f_szin_auto_db('piros');
dopl(v);
end;

select f_szin_auto_db('piros')
from dual;

declare
  v szerelo.sz_auto%rowtype;
begin
select *
into v
from szerelo.sz_auto
where rendszam='SQL339';

dopl(v.azon||' '||v.szin);

end;


create or replace procedure proc_param( 
     p_a varchar2:='alma', 
     p_b in varchar2, 
     p_c out varchar2, 
     p_d in out varchar2) is
begin
dopl(p_a);
--p_a:='korte';
dopl(p_b);

dopl(nvl(p_c,'null'));
p_c:='kortefa';
dopl(nvl(p_d, 'null'));
p_d:='dio';
end;

declare
 v_a varchar2(30):='ananasz';
 v_b varchar2(30):='mandula';
 v_c varchar2(30):='eper';
 v_d varchar2(30):='m?lna';
     
begin
proc_param( v_a, v_b, v_c, v_d);
dopl('c:'||v_c);
dopl('d:'||v_d);

end;

create or replace procedure proc_param2(
   p_a varchar2:='alma', 
   p_b varchar2:='korte', 
   p_c varchar2:='dio', 
   p_d varchar2:='eper') is
begin

dopl(p_a||' '||p_b||' '||p_c||' '||p_d);
end;

begin   
proc_param2;
end;

declare 
   v_c varchar2(20):='ribizli';
   
begin   
proc_param2(p_c=>v_c);
end;

declare 
   v_a varchar2(20):='malna';
   v_b varchar2(20):='barack'; 
   v_c varchar2(20):='ribizli';
   v_d varchar2(20):='szam?ca';
   
begin   
proc_param2(p_c=>v_c, p_a=>v_a, p_d=>v_d);
end;

declare 
   v_a varchar2(20):='malna';
   v_b varchar2(20):='barack'; 
   v_c varchar2(20):='ribizli';
   v_d varchar2(20):='szam?ca';
   
begin   
proc_param2(v_a, v_b, v_c);
end;

declare 
   v_a varchar2(20):='malna';
   v_b varchar2(20):='barack'; 
   v_c varchar2(20):='ribizli';
   v_d varchar2(20):='szam?ca';
   
begin   
proc_param2(v_a, v_b, p_d=>v_d);
end;

declare 
  kiv exception;
begin
  raise kiv;
end;

begin
  raise_application_error(-20001, 'Az ?n kiv?telem');
end;

begin
for i in -3..3
  loop
  dopl(1000/i);
  end loop;

exception
  when OTHERS
  then null;
end;

begin
for i in -3..3
  loop
  dopl(1000/i);
  end loop;

exception
  when OTHERS
  then dopl(sqlcode||' '||sqlerrm);
end;

begin
for i in -3..3
  loop
  dopl(1000/i);
  end loop;

exception
  when zero_divide
  then dopl(sqlcode||' '||sqlerrm);
end;

declare 
  v number(3);
begin
for i in -3..3
  loop
  v:=1000/i;
  dopl(v);
  end loop;

exception
  when zero_divide or value_error
  then dopl(sqlcode||' '||sqlerrm);
  when others
  then dopl('Tov?bb dobjuk a kiv?telt');
       raise;
end;

declare 
  v number(3);--number(4);
begin
for i in -3..3
  loop
  --raise_application_error(-20002, 'hello');
  v:=1000/i;
  dopl(v);
  end loop;

exception
  when zero_divide
  then dopl('0-val val? oszt?s');
  when value_error
  then dopl('?rt?k hiba');
  when others
  then dopl('Tov?bb dobjuk a kiv?telt');
       raise;
end;


declare 
  v number(3);--number(4);
begin
for i in -3..3
  loop
    begin
     raise_application_error(-20002, 'hello');
     v:=1000/i;
     dopl(v);
  
     exception
      when zero_divide
      then dopl('0-val val? oszt?s');
      when value_error
      then dopl('?rt?k hiba');
    end;
  end loop;

exception
  when others
  then dopl('Tov?bb dobjuk a kiv?telt');
       raise;
end;

drop table szamok;
create table szamok (sz number(5) not null);

declare 
  kiv exception;
  pragma exception_init(kiv, -1400);
begin
insert into szamok(sz) values(null);
exception
  when kiv 
  then dopl('Elkaptuk');
end;

declare 
v szerelo.sz_auto%rowtype;

begin
select *
into v
from szerelo.sz_auto
where elso_vasarlasi_ar=3500001;
dopl(v.rendszam);
exception
  when no_data_found
  then dopl('nincs ilyen sor');
end;


declare 
v szerelo.sz_auto%rowtype;

begin
select *
into v
from szerelo.sz_auto
where elso_vasarlasi_ar=2300000;
dopl(v.rendszam);
exception
  when no_data_found
  then dopl('nincs ilyen sor');
  when too_many_rows
  then dopl('T?l sok ilyen sor');
end;