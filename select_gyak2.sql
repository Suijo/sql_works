Melyik aut?t szerelt?k a legkevesebbszer?
select au.rendszam, count(sz.szereles_kezdete)
from szerelo.sz_auto au left outer join
szerelo.sz_szereles sz
on au.azon=sz.auto_azon
group by au.rendszam, au.azon
having count(sz.szereles_kezdete)=(select min(count(sz.szereles_kezdete))
                                   from szerelo.sz_auto au left outer join
                                   szerelo.sz_szereles sz
                                   on au.azon=sz.auto_azon
                                   group by au.rendszam, au.azon);

with bs as (select au.rendszam, count(sz.szereles_kezdete) db
            from szerelo.sz_auto au left outer join
            szerelo.sz_szereles sz
            on au.azon=sz.auto_azon
            group by au.rendszam, au.azon)
select *
from bs 
where db=(select min(db) from bs);


Melyik aut?nak van a legkisebb els?_v?s?rl?si_?ra?
select *
from szerelo.sz_auto
where elso_vasarlasi_ar=(select min(elso_vasarlasi_ar)
                         from szerelo.sz_auto);
                         
Melyik tulajdonosnak van a legkevesebb aut?ja?
select tu.nev, count(atu.auto_azon)
from SZERELO.sz_tulajdonos tu left outer join
SZERELO.sz_auto_tulajdonosa atu
on tu.azon=atu.tulaj_azon
group by tu.nev, tu.azon
having count(atu.auto_azon)=(select min(count(atu.auto_azon))
                        from SZERELO.sz_tulajdonos tu left outer join
                        SZERELO.sz_auto_tulajdonosa atu
                        on tu.azon=atu.tulaj_azon
                        group by tu.nev, tu.azon);
                        
Az egyes tulajdonosoknak melyik az utolj?ra v?s?rolt aut?juk?
(auto_azon, tulaj nev);   

select tu.nev, ut_tulaj.auto_azon, ut_tulaj.vasarlas_ideje
from szerelo.sz_tulajdonos tu left outer join (select * from szerelo.sz_auto_tulajdonosa
                                            where (tulaj_azon, vasarlas_ideje) in 
                                              (select tulaj_azon, max(vasarlas_ideje)
                                               from szerelo.sz_auto_tulajdonosa
                                               group by tulaj_azon)) ut_tulaj
on tu.azon=ut_tulaj.tulaj_azon;  

Az egyes tulajdonosoknak melyik az utolj?ra v?s?rolt aut?juk?
(rendszam, tulaj nev);

select tu.nev, ut_tulaj.auto_azon, ut_tulaj.vasarlas_ideje, rendszam
from szerelo.sz_tulajdonos tu left outer join (select * from szerelo.sz_auto_tulajdonosa
                                            where (tulaj_azon, vasarlas_ideje) in 
                                              (select tulaj_azon, max(vasarlas_ideje)
                                               from szerelo.sz_auto_tulajdonosa
                                               group by tulaj_azon)) ut_tulaj
on tu.azon=ut_tulaj.tulaj_azon
left outer join szerelo.sz_auto au
on ut_tulaj.auto_azon=au.azon
;      

T?r?lj?k azon autofelertekel?seket, amelyek eset?n az ?rt?k t?bb, 
mint az aut? els? v?s?rl?si ?ra.
drop table sz_autofelertekeles;
create table sz_autofelertekeles as
select *
from SZERELO.sz_autofelertekeles;

delete 
from sz_autofelertekeles af --ide nem lehet m?st ?rni
where ertek>(select elso_vasarlasi_ar*0.8
             from szerelo.sz_auto au
             where af.auto_azon=au.azon);
             
T?r?lj?k azon tulajdonosokat, akiknek nincs aut?juk.             
create table sz_tulajdonos as
select *
from SZERELO.sz_tulajdonos;

delete
from sz_tulajdonos
where azon not in (select tulaj_azon from SZERELO.sz_auto_tulajdonosa);

M?dos?tsuk azon szerel?sek ?r?t, amelyeket a leghosszabb nev? szerelomuhelyekben v?geztek.
Az ?j ?r legyen az aut? elso_vasarlasi_aranak a 10-ed r?sze.
drop table sz_szereles;
create table sz_szereles as select * from szerelo.sz_szereles;

update sz_szereles sz
set munkavegzes_ara=(select elso_vasarlasi_ar/10 
                     from szerelo.sz_auto au
                     where sz.auto_azon=au.azon)
where muhely_azon in (select azon
                     from szerelo.sz_szerelomuhely
                     where length(nev)=(select max(length(nev))
                                        from szerelo.sz_szerelomuhely));
                                        
M?dos?tsuk azon auto_tulajdonl?sok v?s?rl?si idej?t, 
amelyek eset?n a megv?s?rolt aut?t 3-n?l t?bbsz?r szerelt?k. 
Az ?j v?s?rl?si id? legyen az utols? befejezett munkav?gz?s v?ge;  
drop table sz_auto_tulajdonosa;
create table sz_auto_tulajdonosa as
select * from SZERELO.sz_auto_tulajdonosa;

update sz_auto_tulajdonosa atu
set vasarlas_ideje=(select max(szereles_vege)
                    from szerelo.sz_szereles sz
                    where atu.auto_azon=sz.auto_azon)
                    
where auto_azon in (select auto_azon
                    from szerelo.sz_szereles
                    group by auto_azon 
                    having count(szereles_kezdete)>3);
                    
T?r?lj?k azokat a szerel?seket, amelyekhez tartoz? 
aut?t utolj?ra Kiss Zolt?n v?s?rolta meg;   
drop table sz_szereles;
create table sz_szereles as select * from szerelo.sz_szereles;

delete
from sz_szereles sz
where auto_azon in (select auto_azon
                    from SZERELO.sz_auto_tulajdonosa atu
                    where (auto_azon, vasarlas_ideje) in (select auto_azon, max(vasarlas_ideje)
                                                          from SZERELO.sz_auto_tulajdonosa atu
                                                          group by auto_azon)
                     and tulaj_azon in (    select azon
                                            from SZERELO.sz_tulajdonos
                                            where nev='Kiss Zolt?n')  )                                  ;
;
                    
/*select *
from SZERELO.sz_auto_tulajdonosa atu
where atu.tulaj_azon in (select azon
                        from SZERELO.sz_tulajdonos
                        where nev='Kiss Zolt?n')
;
select auto_azon
from SZERELO.sz_auto_tulajdonosa atu
where (auto_azon, vasarlas_ideje) in (select auto_azon, max(vasarlas_ideje)
                                        from SZERELO.sz_auto_tulajdonosa atu
                                        group by auto_azon)
and tulaj_azon in (    select azon
                        from SZERELO.sz_tulajdonos
                        where nev='Kiss Zolt?n')                                    ;*/
                        
M?dos?tsuk azon szerel?seket, amelyek olyan aut?khoz tartoznak, amelyeknek eset?n a szerel?s kezdete 
5 ?vvel k?s?bb kezd?d?tt, mint az els? v?s?rl?s datuma. 
A szerel?s munkav?gz?s?nek az ?ra legyen a az eredeti munkav?gz?s ?ra minusz 
az aut? els? v?s?rl?si ?r?nak az 1 sz?zal?ka                        

add_months(sysdate, 5*12)
months_between(date1, date2)/12>5;

update sz_szereles sz
set munkavegzes_ara=munkavegzes_ara-(select 0.1*elso_vasarlasi_ar
                                     from szerelo.sz_auto au
                                     where sz.auto_azon=au.azon)
where auto_azon in (select azon
                    from szerelo.sz_auto au
                    where sz.szereles_kezdete>add_months(au.elso_vasarlas_idopontja, 5*12));
                    
                    
/*                    rollback;
alter table sz_szereles add (elso_vasarlasi_idopont date);        

update sz_szereles sz
set elso_vasarlasi_idopont=(select elso_vasarlas_idopontja
                                     from szerelo.sz_auto au
                                     where sz.auto_azon=au.azon)
where auto_azon in (select azon
                    from szerelo.sz_auto au
                    where sz.szereles_kezdete>add_months(au.elso_vasarlas_idopontja, 12*12));
                    
select auto_azon, to_char(szereles_kezdete, 'yyyy.mm.dd'), to_char(elso_vasarlasi_idopont, 'yyyy.mm.dd')
from sz_szereles
order by auto_azon;*/

/*M?dos?tsuk azon szerel?seket, amelyek eset?n a szerel?s kezdete 
5 ?vvel k?s?bb kezd?d?tt, mint az aut? els? v?s?rl?s datuma. 
A szerel?s munkav?gz?s?nek az ?ra legyen a az eredeti munkav?gz?s ?ra minusz 
az aut? els? v?s?rl?si ?r?nak az 1 sz?zal?ka;

update sz_szereles sz
set munkavegzes_ara=munkavegzes_ara-(select 0.1*elso_vasarlasi_ar
                                     from szerelo.sz_auto au
                                     where sz.auto_azon=au.azon)
where szereles_kezdete>(select add_months(au.elso_vasarlas_idopontja, 5*12)
                    from szerelo.sz_auto au
                    where au.azon=sz.auto_azon);*/
