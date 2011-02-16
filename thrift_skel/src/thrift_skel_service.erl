-module(SKEL_SHORTNAME_service).

-include("SKEL_ERLANGIFIED_LONGNAME_thrift.hrl").
-include("SKEL_SHORTNAME_types.hrl").

-export([start_link/0, stop/1,
         handle_function/2

% Thrift implementations
% FILL IN HERE
         ]).

%%%%% EXTERNAL INTERFACE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_link() ->
  thrift_socket_server:start ([{port, get_port()},
                               {name, ?MODULE},
                               {service, SKEL_ERLANGIFIED_LONGNAME_thrift},
                               {handler, ?MODULE},
                               {framed, true},
                               {socket_opts, [{recv_timeout, 60*60*1000}]}]).

stop(_Server) ->
  thrift_socket_server:stop (?MODULE),
  ok.

%%%%% THRIFT INTERFACE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_function(Function, Args) when is_atom(Function), is_tuple(Args) ->
  case apply(?MODULE, Function, tuple_to_list(Args)) of
    ok -> ok;
    Reply -> {reply, Reply}
  end.

%%%%% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_port() ->
  {ok, Result} = application:get_env(SKEL_SHORTNAME, service_port),
  Result.

%% ADD THRIFT FUNCTIONS HERE
