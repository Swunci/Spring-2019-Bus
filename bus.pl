:-[constraintLib].
% Create the edges 
edge(X,Y) :-
    bus(_Bus,X,Y); 
    bus(_Bus,Y,X).

connected(X, Y) :-
    edge(X, Y), edge(Y,X).

% helper methods
   
member(X, [X|_]).
member(X, [_|Ys]) :-
    member(X, Ys).

dif(X, Y) :- 
    when(?=(X,Y), X \== Y).

% Calculates the time it takes to reach next station on the path
calculateTime(Start, Start, _Total, _Y).
calculateTime(Start, End, Total, Y) :-
    Distance is abs(Start - End),
    % Total % Distance will tell us if the bus is in transit or not
    % If Total % Distance returns 0, that means the bus is not in transit and is at a station
    	% Bus is at a station
    (   0 is mod(Total, Distance) ->  
    			% Total/Distance will get us the number of times the bus moves from one station to another
        	(   0 is mod(Total/Distance, 2) ->  
            		(	Start < End ->  
                    		Y = Total + Distance
                    	;   Y = Total + 2 * Distance
                    )
            	% Odd number of trips
            	;   (   Start < End ->  
                    		Y = Total + 2 * Distance
                    	;   Y = Total + Distance
                    )
            )
   		% Bus is in transit
    		% A is the distance the bus needs to travel to reach its destination station.
    	;	A is Distance - mod(Total, Distance),
        	% Round (Total/Distance) up to get the number of trips the bus made from one station to another
        	(   0 is mod(ceiling(Total/Distance), 2) -> 
            		(   Start < End ->  
                    		Y = Total + Distance + A
                    	;   Y = Total + 2 * Distance + A
                    )
            	% Odd number of trips
            	;   (   Start < End ->  
                    		Y = Total + 2 * Distance + A
                    	;   Y = Total + Distance + A
                    )
            )    	
    ).

path(Start, End, Path, Time) :-
    path(Start, End, [], Path, Time, 0).
path(Start, Start, _, [Start], Time, Total) :-
    Time is Total.
path(Start, End, Visited, [Start|Nodes], Time, Total) :-
    \+ member(Start, Visited),
    \+ Start is End,
    dif(Start, Node),
    connected(Start,Node),
    calculateTime(Start, Node, Total, Y),
    path(Node, End, [Start|Visited], Nodes, Time, Y).

min_list([Min], Min).
min_list([X,Y|T], Min) :-
    X >= Y,
    min_list([Y|T], Min).
min_list([X,Y|T], Min) :-
    X < Y,
    min_list([X|T], Min).
    
% Main

min_time(Time) :-
    last(End),
    bus(1, Start, _),
    findall(T, path(Start, End, _, T), L),
	min_list(L, Time).

