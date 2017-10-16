item(balloons).
item(candles).
item(chocolates).
item(placecards).
item(streamers).
 
customer(jeremy).
customer(stella).
customer(hugh).
customer(leroy).
customer(ida).
 
event(anniversary).
event(charityAuction).
event(retirement).
event(seniorProm).
event(wedding).

rose(cottageBeauty).
rose(goldenSunset).
rose(mountainBloom).
rose(pinkParadise).
rose(sweetDreams).

solve :-
    item(JeremyItem), item(StellaItem), item(HughItem), item(LeroyItem), item(IdaItem),
    all_different([JeremyItem, StellaItem, HughItem, LeroyItem, IdaItem]),

    event(JeremyEvent), event(StellaEvent), event(HughEvent), event(LeroyEvent), event(IdaEvent),
    all_different([JeremyEvent, StellaEvent, HughEvent, LeroyEvent, IdaEvent]),
	
	rose(JeremyRose), rose(StellaRose), rose(HughRose), rose(LeroyRose), rose(IdaRose),
    all_different([JeremyRose, StellaRose, HughRose, LeroyRose, IdaRose]),
 
    Quartets = [ [jeremy, JeremyItem, JeremyEvent, JeremyRose],
                [stella, StellaItem, StellaEvent, StellaRose],
                [hugh, HughItem, HughEvent, HughRose],
				[ida, IdaItem, IdaEvent, IdaRose],
                [leroy, LeroyItem, LeroyEvent, LeroyRose] ],
				
	member([jeremy, _, seniorProm, _], Quartets),
	\+ member([stella, _, wedding, _], Quartets),
	member([stella, _, _, cottageBeauty], Quartets),
	member([hugh, _, _, pinkParadise], Quartets),
	\+ member([hugh, _, charityAuction, _], Quartets),
	\+ member([hugh, _, wedding, _], Quartets),
	member([_, streamers, anniversary, _], Quartets),
	member([_, balloons, wedding, _], Quartets),
	member([_, chocolates, _, sweetDreams], Quartets),
	\+ member([jeremy, _, _, mountainBloom], Quartets),
	member([leroy, _, retirement, _], Quartets),
	member([_, candles, seniorProm, _], Quartets),
	
	tell(jeremy, JeremyItem, JeremyEvent, JeremyRose),
    tell(stella, StellaItem, StellaEvent, StellaRose),
    tell(hugh, HughItem, HughEvent, HughRose),
	tell(leroy, LeroyItem, LeroyEvent, LeroyRose),
    tell(ida, IdaItem, IdaEvent, IdaRose).
	
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(W, X, Y, Z) :-
    write('Customer '), print(W), write(' got the item '), write(X), write(' for the event '), write(Y),
    write(' with roses of type '), write(Z), write('.'), nl.
