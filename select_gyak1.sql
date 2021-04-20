--alter user u_neptunkod identified by jelszo;

select *
from szerelo.sz_auto;

List?zza az Opel vagy Ford m?rk?j? k?k aut?k rendsz?m?t ?s els? v?s?rl?si ?r?t.;
select rendszam, elso_vasarlasi_ar
from SZERELO.sz_auto au inner join szerelo.sz_autotipus ati
on au.tipus_azon=ati.azon
where szin='k?k'
and marka in ('Opel', 'Ford');

Az egyes sz?nekhez h?ny aut? tartozik?;
select szin, count(*)
from szerelo.sz_auto
group by szin;

Melyek azok a sz?nek, amelyekhez 10-n?l t?bb aut? tartozik?
select szin, count(*)
from szerelo.sz_auto
group by szin
having count(*)>10;

Melyek azok a t?pusok, amelyekhez 10-n?l kevesebb aut? tartozik?;
select ati.marka, ati.megnevezes, count(au.azon)
from SZERELO.sz_auto au right outer join szerelo.sz_autotipus ati
on au.tipus_azon=ati.azon
group by ati.megnevezes, ati.azon, ati.marka
having count(au.azon)<10;

Melyek azok a tulajdonosok, akiknek 5-n?l kevesebb aut?juk van? 
select tu.nev, count(atu.auto_azon)
from szerelo.sz_tulajdonos tu left outer join
SZERELO.sz_auto_tulajdonosa atu
on tu.azon=atu.tulaj_azon
group by tu.nev, tu.azon
having count(atu.auto_azon)<5
order by tu.nev;

Melyik aut?nak van az legkisebb els? v?s?rl?si ?ra?
select *
from szerelo.sz_auto
where elso_vasarlasi_ar=(select min(elso_vasarlasi_ar)
                       from szerelo.sz_auto);

Melyik aut?nak (rendsz?m, sz?n) van a legkisebb fel?rt?kel?si ?rt?ke?
select azon, rendszam, szin
from szerelo.sz_auto
where azon=(select auto_azon
            from szerelo.sz_autofelertekeles
            where ertek=(select min(ertek)
                         from szerelo.sz_autofelertekeles));

Melyik aut?nak (rendsz?m, sz?n) van a legkisebb fel?rt?kel?si ?rt?ke, ?s mennyi ez az ?rt?k?
select auto_azon, ertek, rendszam, szin
from szerelo.sz_autofelertekeles af inner join
szerelo.sz_auto au
on af.auto_azon=au.azon
where ertek=(select min(ertek)
             from szerelo.sz_autofelertekeles);


select azon, rendszam , szin, ertek
from szerelo.sz_auto au inner join (select auto_azon, ertek
                                    from szerelo.sz_autofelertekeles 
                                    where ertek=(select min(ertek)
                                                 from szerelo.sz_autofelertekeles)) bs
on bs.auto_azon=au.azon;       

Az egyes aut?kat mikor szerelt?k utolj?ra (szereles_kezdete) (befejezett szereles), auto_azon (szereles).
select auto_azon, max(szereles_kezdete)
from szerelo.sz_szereles
where szereles_vege is not null
group by auto_azon;


Az egyes aut?kat mikor szerelt?k utolj?ra (szereles_kezdete) (befejezett szereles), auto_azon, rendszam, szin.
select au.azon, rendszam, szin, szk
from szerelo.sz_auto au left outer join (select auto_azon, max(szereles_kezdete) szk
                                      from szerelo.sz_szereles
                                      where szereles_vege is not null
                                      group by auto_azon) bs
on au.azon=bs.auto_azon;

Az egyes tulajdonosoknak melyik az utolj?ra v?s?rolt aut?juk?
(auto_azon, tulaj_azon);
select *
from szerelo.sz_auto_tulajdonosa
where (tulaj_azon, vasarlas_ideje) in (select tulaj_azon, max(vasarlas_ideje)
                                      from szerelo.sz_auto_tulajdonosa
                                      group by tulaj_azon);

select *
from szerelo.sz_auto_tulajdonosa atu inner join (select tulaj_azon, max(vasarlas_ideje) vi
                                      from szerelo.sz_auto_tulajdonosa
                                      group by tulaj_azon) bs
on atu.tulaj_azon=bs.tulaj_azon
and atu.vasarlas_ideje=bs.vi;

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
