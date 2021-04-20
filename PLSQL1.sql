
begin
dbms_output.put_line('Hello');
end;
/

declare
v varchar2(30);
v2 varchar2(30):='almafa';
begin
null;
end;


declare
v varchar2(30);
v2 varchar2(30):='almafa';
begin
dbms_output.put_line(nvl(v,'null')||' '||v2);
end;

declare
v number(5):=100;
v2 number(5):=500;
begin
if v>v2
   then dbms_output.put_line(v||' nagyobb, mint '||v2);
   else dbms_output.put_line(v||' nem nagyobb, mint '||v2);
end if;
end;


declare
v number(5):=100;
v2 number(5):=500;
v3 number(5):=1000;
begin
if v>v2
   then if v2>v3
        then dbms_output.put_line(v||'>'||v2||'>'||v3);
        else dbms_output.put_line(v||'>'||v2||' '||v2||'<='||v3);
        end if;
   elsif v>v3
      then dbms_output.put_line(v3||'<'||v||'<='||v2);
   else dbms_output.put_line(v||'<='||v2||' '|| v||'<='||v3);
end if;
end;



begin
for i in (select * from szerelo.sz_auto)
  loop
  if i.elso_vasarlasi_ar>100000
    then   dbms_output.put_line(i.rendszam||' '||i.szin);
  end if;
  end loop;
end;

drop table s_auto;
create table s_auto as select * from szerelo.sz_auto;

begin
INSERT INTO s_auto (azon,szin,elso_vasarlas_idopontja,elso_vasarlasi_ar,tipus_azon,rendszam) 
VALUES (1000,'k?k',sysdate,500,null,'KLM123');
commit;
end;


begin
delete 
from s_auto
where rendszam='KLM123';
commit;
end;


begin
delete s_auto;
for i in (select * from szerelo.sz_auto)
 loop
   INSERT INTO s_auto (    azon,    szin,    elso_vasarlas_idopontja,    elso_vasarlasi_ar,    tipus_azon,    rendszam) 
   VALUES (i.azon,    i.szin,    i.elso_vasarlas_idopontja,    i.elso_vasarlasi_ar,    i.tipus_azon,    i.rendszam);
 end loop;
 commit;
end;