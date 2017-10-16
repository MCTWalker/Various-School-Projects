subject(english).
subject(gym).
subject(history).
subject(math).
subject(science).
 
teacher(appleton).
teacher(gross).
teacher(knight).
teacher(mcevoy).
teacher(parnell).
 
state(california).
state(florida).
state(maine).
state(oregon).
state(virginia).

activity(antiquing).
activity(camping).
activity(sightseeing).
activity(spelunking).
activity(waterskiing).

solve :-
    subject(Appletonsubject), subject(Grosssubject), subject(Knightsubject), subject(Mcevoysubject), subject(Parnellsubject),
    all_different([Appletonsubject, Grosssubject, Knightsubject, Mcevoysubject, Parnellsubject]),

    state(Appletonstate), state(Grossstate), state(Knightstate), state(Mcevoystate), state(Parnellstate),
    all_different([Appletonstate, Grossstate, Knightstate, Mcevoystate, Parnellstate]),
	
	activity(Appletonactivity), activity(Grossactivity), activity(Knightactivity), activity(Mcevoyactivity), activity(Parnellactivity),
    all_different([Appletonactivity, Grossactivity, Knightactivity, Mcevoyactivity, Parnellactivity]),
 
    Quartets = [ [appleton, Appletonsubject, Appletonstate, Appletonactivity],
                [gross, Grosssubject, Grossstate, Grossactivity],
                [knight, Knightsubject, Knightstate, Knightactivity],
				[parnell, Parnellsubject, Parnellstate, Parnellactivity],
                [mcevoy, Mcevoysubject, Mcevoystate, Mcevoyactivity] ],
				
	member([gross, math, _, _], Quartets),
	member([gross, science, _, _], Quartets),
	member([gross, _, florida, antiquing], Quartets),
	member([gross, _, california, _], Quartets),
	\+ member([gross, _, california, antiquing], Quartets),
	
	member([_, science, waterskiing, california], Quartets),
	member([_, science, waterskiing, florida], Quartets),
	member([knight, _, _, pinkParadise], Quartets),
	
	
	\+ member([gross, _, wedding, _], Quartets),
	member([gross, _, _, cottageBeauty], Quartets),
	member([knight, _, _, pinkParadise], Quartets),
	\+ member([knight, _, charityAuction, _], Quartets),
	\+ member([knight, _, wedding, _], Quartets),
	member([_, streamers, anniversary, _], Quartets),
	member([_, english, wedding, _], Quartets),
	member([_, chocolates, _, sweetDreams], Quartets),
	\+ member([appleton, _, _, mountainBloom], Quartets),
	member([mcevoy, _, retirement, _], Quartets),
	member([_, candles, seniorProm, _], Quartets),
	
	tell(appleton, Appletonsubject, Appletonstate, Appletonactivity),
    tell(gross, Grosssubject, Grossstate, Grossactivity),
    tell(knight, Knightsubject, Knightstate, Knightactivity),
	tell(mcevoy, Mcevoysubject, Mcevoystate, Mcevoyactivity),
    tell(parnell, Parnellsubject, Parnellstate, Parnellactivity).
	
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(W, X, Y, Z) :-
    write('teacher '), print(W), write(' got the subject '), write(X), write(' for the state '), write(Y),
    write(' with activitys of type '), write(Z), write('.'), nl.
