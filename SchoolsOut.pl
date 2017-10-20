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
				
	(member([gross, math, _, _], Quartets) ; member([gross, science, _, _], Quartets)) ,
	(member([gross, _, _, antiquing], Quartets) ->   member([gross, _, florida, _], Quartets) ; member([gross, _, california, _], Quartets)),
	
	member([mcevoy, history, _, _], Quartets),
	(member([mcevoy, _, maine, _], Quartets) ; member([mcevoy, _, oregon, _], Quartets)) ,
	
	(member([_, science, florida, waterskiing], Quartets) ; member([_, science, california, waterskiing], Quartets)) ,
	
	member([parnell,_,_,spelunking], Quartets),
	
	\+ member([mcevoy, _, virginia, _], Quartets),	
	\+ member([knight, _, virginia, _], Quartets),	
	
	(member([_, english, virginia, _], Quartets) -> member([appleton, _, virginia,  _], Quartets) ; member([parnell, _, virginia, _], Quartets)),

	\+ member([_, gym, maine, _], Quartets),
	\+ member([_, _, maine, sightseeing], Quartets),
	\+ member([gross, _, _, camping], Quartets),
    
	\+ member([mcevoy, _, _, camping], Quartets),	
	\+ member([knight, _, _, camping], Quartets),
    
	\+ member([mcevoy, _, _, antiquing], Quartets),	
	\+ member([knight, _, _, antiquing], Quartets),
	
	tell(appleton, Appletonsubject, Appletonstate, Appletonactivity),
    tell(gross, Grosssubject, Grossstate, Grossactivity),
    tell(knight, Knightsubject, Knightstate, Knightactivity),
	tell(mcevoy, Mcevoysubject, Mcevoystate, Mcevoyactivity),
    tell(parnell, Parnellsubject, Parnellstate, Parnellactivity).
	
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(W, X, Y, Z) :-
    write('teacher '), write(W), write(' teaches the subject '), write(X), write(' is going to the state '), write(Y),
    write(' doing the activity of '), write(Z), write('.'), nl.
