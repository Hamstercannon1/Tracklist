-module(tracklist).
-export([main/0, welcome_hub/0, view_tracklist/1, add_to_tracklist/0, 
         remove_from_tracklist/1, play_track/1, play_tracklist/0, 
         list_artists/0, read_csv/1, write_csv/2]).

% Main function
main() ->
    Path = welcome_hub(),
    handle_path(Path).

% Handle user path from welcome_hub
handle_path(1) ->
    Tracklist = view_tracklist("tracklist.csv"),
    io:format("~p~n", [Tracklist]),
    main();
handle_path(2) ->
    add_to_tracklist(),
    main();
handle_path(3) ->
    io:format("Enter the track number to remove: "),
    {ok, [Index]} = io:fread("", "~d"),
    remove_from_tracklist(Index),
    main();
handle_path(4) ->
    play_tracklist(),
    main();
handle_path(5) ->
    io:format("Enter the filename to play: "),
    {ok, Filename} = io:get_line(""),
    play_track(string:trim(Filename)),
    main();
handle_path(6) ->
    Artists = list_artists(),
    io:format("Artists: ~p~n", [Artists]),
    main();
handle_path(7) ->
    io:format("Thank you for stopping by! Have a wonderful day! :)~n");
handle_path(_) ->
    io:format("Invalid Response. Please select again :)~n"),
    main().

% Welcome menu
welcome_hub() ->
    io:format("Welcome to the tracklist!~n
1. View Tracklist~n
2. Add Song to Tracklist~n
3. Remove Song from Tracklist~n
4. Play Tracklist~n
5. Play Individual Track~n
6. List Artists~n
7. Close Program~n"),
    {ok, [Path]} = io:fread("What would you like to do? ", "~d"),
    Path.

% View tracklist
view_tracklist(Filename) ->
    {ok, Content} = file:read_file(Filename),
    Tracklist = read_csv(Content),
    Tracklist.

% Add a song to tracklist
add_to_tracklist() ->
    % Initialize an empty track
    NewTrack = [],
    
    % Get and trim user input
    TrackNumber = string:to_integer(string:trim(io:get_line("Track Number: "))),
    TrackName = string:trim(io:get_line("Track Name: ")),
    ArtistName = string:trim(io:get_line("Artist Name: ")),
    Filename = string:trim(io:get_line("Filename: ")),

    % Debugging: Print trimmed values
    io:format("Track Number: ~p~n", [TrackNumber]),
    io:format("Track Name: ~s~n", [TrackName]),
    io:format("Artist Name: ~s~n", [ArtistName]),
    io:format("Filename: ~s~n", [Filename]),

    % Prepare the new track entry
    NewTrack = [TrackNumber, TrackName, ArtistName, Filename],

    % Read existing tracklist from the CSV
    Tracklist = view_tracklist("tracklist.csv"),

    % Append the new track to the CSV file
    case file:open("tracklist.csv", [append]) of
        {ok, File} ->
            ok = csv:write_row(File, NewTrack),
            file:close(File),
            io:format("Data added to CSV file successfully.~n");
        {error, Reason} ->
            io:format("Failed to open file: ~p~n", [Reason])
    end.

% Remove a song from tracklist
remove_from_tracklist(Index) ->
    Tracklist = view_tracklist("tracklist.csv"),
    UpdatedTracklist = lists:delete(lists:nth(Index, Tracklist), Tracklist),
    write_csv("tracklist.csv", UpdatedTracklist),
    io:format("Track removed successfully.~n").

% Play individual track (simulated by printing the track name)
play_track(Filename) ->
    io:format("Playing ~s...~n", [Filename]),
    os:cmd("mpg123 " ++ Filename).

% Play the entire tracklist
play_tracklist() ->
    Tracklist = view_tracklist("tracklist.csv"),
    lists:foreach(fun({_, TrackName, ArtistName, FileName}) -> % Renamed Filename to FileName
                          io:format("Now playing: ~s by ~s~n", [TrackName, ArtistName]),
                          play_track(FileName)
                  end, Tracklist).

% List all artists
list_artists() ->
    Tracklist = view_tracklist("tracklist.csv"),
    Artists = lists:usort([Artist || {_, _, Artist, _} <- Tracklist]),
    Artists.

% Read CSV file (manual CSV parser)
read_csv(Content) ->
    Lines = string:tokens(binary_to_list(Content), "\n"),
    lists:map(fun(Line) -> string:tokens(Line, ",") end, Lines).

% Write CSV file (manual CSV writer)
write_csv(Filename, Tracklist) ->
    FileContent = lists:map(fun({TrackNumber, TrackName, ArtistName, Filename}) ->
                                 TrackNumberString = integer_to_list(TrackNumber),
                                 string:join([TrackNumberString, TrackName, ArtistName, Filename], ",")
                             end, Tracklist),
    file:write_file(Filename, string:join(FileContent, "\n")).
