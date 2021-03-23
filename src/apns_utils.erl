%%% @doc Contains util functions.
%%%
%%% Copyright 2017 Erlang Solutions Ltd.
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%% @end
%%% @copyright Inaka <hello@inaka.net>
%%%
-module(apns_utils).
-author("Felipe Ripoll <felipe@inakanetworks.com>").

% API
-export([ sign/2
        , epoch/0
        , bin_to_hexstr/1
        , seconds_to_timestamp/1
        ]).

-export_type([ sign_opts/0 ]).

-type sign_opts() :: #{ method  => atom()
                      , openssl => binary()
                      , keyfile => binary()
                      }.

%%%===================================================================
%%% API
%%%===================================================================

%% Signs the given binary.
-spec sign(binary(), sign_opts()) -> binary().
sign(Data, #{ method := openssl, openssl := Openssl, keyfile := KeyFile }) ->
  Command = "printf '" ++ binary_to_list(Data) ++ "'" ++
            " | " ++ Openssl ++ " dgst -binary -sha256 -sign " ++ KeyFile ++
            " | base64",
  {0, Result} = apns_os:cmd(Command),
  strip_b64(list_to_binary(Result));
sign(Data, #{ method := public_key, keyfile := KeyFile }) ->
  {ok, PemBin} = file:read_file(KeyFile),
  [KeyEntry] = public_key:pem_decode(PemBin),
  PrivateKey = public_key:pem_entry_decode(KeyEntry),
  base64:encode(public_key:sign(Data, sha256, PrivateKey)).

%% Retrieves the epoch date.
-spec epoch() -> integer().
epoch() ->
  {M, S, _} = os:timestamp(),
  M * 1000000 + S.

%% Converts binary to hexadecimal string().
-spec bin_to_hexstr(binary()) -> string().
bin_to_hexstr(Binary) ->
  L = size(Binary),
  Bits = L * 8,
  <<X:Bits/big-unsigned-integer>> = Binary,
  F = lists:flatten(io_lib:format("~~~B.16.0B", [L * 2])),
  lists:flatten(io_lib:format(F, [X])).

%% Converts from seconds to datetime.
-spec seconds_to_timestamp(pos_integer()) -> calendar:datetime().
seconds_to_timestamp(Secs) ->
  Epoch = 62167219200,
  calendar:gregorian_seconds_to_datetime(Secs + Epoch).


%% Remove newline and equality characters
-spec strip_b64(binary()) -> binary().
strip_b64(BS) ->
  binary:list_to_bin(binary:split(BS, [<<"\n">>, <<"=">>], [global])).
