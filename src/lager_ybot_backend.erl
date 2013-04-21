-module(lager_ybot_backend).

-behaviour(gen_event).

%% api
-export([init/1, handle_call/2, handle_event/2, handle_info/2, terminate/2, code_change/3]).

%% test api
-export([test/0]).

%% internal state
-record(state, {
        name = "" :: string(),
        % ybot http host
        host = "" :: string(),
        % ybot http port
        port = 0 :: integer(),
        % log level
        level
}).

init(Params) ->
    % start inets
    inets:start(),
    % get ybot host from config
    YbotHost = config(ybot_host, Params, "http://localhost"),
    % get ybot port from config
    YbotPort = config(ybot_port, Params, 8080),
    % Get name
    Name = config(name, Params, lager_ybot_backend),
    % Get log level
    Level = config(level, Params, error),
    % init state
    {ok, #state{name = Name, level = Level, host = YbotHost, port = YbotPort}}.
    
handle_call(_Request, State) ->
  {ok, ok, State}.
  
%% @doc log messages  
handle_event({log, LagerMessage}, #state{ host = Host, port = Port} = State) ->
    % Make url
    Url = Host ++ ":" ++ integer_to_list(Port),
    case lager_msg:severity(LagerMessage) of
        error ->
            % Make message
            Message = lager_msg:message(LagerMessage),
            % Make json
            Json = list_to_binary("{\"type\":\"broadcast\",\"content\":\"" ++ Message ++ "\"}"),
            % send log error
            httpc:request(post, {Url, [], "application/json", Json}, [], []);
        _ ->
            % do nothing
            pass
    end,
    % return state
    {ok, State};
    
handle_event(_Event, State) ->
    {ok, State}.
    
handle_info(_Info, State) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
    
%% @doc Get parameters from config
config(C, Params, Default) ->
  case lists:keyfind(C, 1, Params) of
    {C, Value} -> 
        % return value
        Value;
    _ -> 
        % not find. return default
        Default
  end.
  
%% @doc TEST api
test() ->
    application:load(lager),
    application:set_env(lager, handlers, [{lager_console_backend, debug}, {lager_ybot_backend, []}]),
    application:set_env(lager, error_logger_redirect, false),
    application:start(lager),
    lager:log(info, self(), "Test INFO message"),
    lager:log(debug, self(), "Test DEBUG message"),
    lager:log(error, self(), "Test ERROR message").
