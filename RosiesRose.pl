all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

item(Balloons).
item(Candles).
item(Chocolates).
item(Placecards).
item(Streamers).
 
customer(Jeremy).
customer(Stella).
customer(Hugh).
customer(Leroy).
customer(Ida).
 
Event(Anniversary).
Event(CharityAuction).
Event(Retirement).
Event(SeniorProm).
Event(Wedding).

Rose(CottageBeauty).
Rose(GoldenSunset).
Rose(MountainBloom).
Rose(PinkParadise).
Rose(SweetDreams).

solve :-
    item(JeremyItem), item(StellaItem), item(HughItem), item(LeroyItem), item(IdaItem),
    all_different([JeremyItem, StellaItem, HughItem, LeroyItem, IdaItem]),

    event(JeremyEvent), event(StellaEvent), event(HughEvent), event(LeroyEvent), event(IdaEvent),
    all_different([JeremyEvent, StellaEvent, HughEvent, LeroyEvent, IdaEvent]),
	
	Rose(JeremyRose), Rose(StellaRose), Rose(HughRose), Rose(LeroyRose), Rose(IdaRose),
    all_different([JeremyRose, StellaRose, HughRose, LeroyRose, IdaRose]),
 
    Quartets = [ [Jeremy, JeremyItem, JeremyEvent, JeremyRose],
                [Stella, StellaItem, StellaEvent, StellaRose],
                [Hugh, HughItem, HughEvent, HughRose],
				[Ida, IdaItem, IdaEvent, IdaRose],
                [Leroy, LeroyItem, LeroyEvent, LeroyRose] ],
				
	\+ member([Stella, _, Wedding, _], Quartets),
