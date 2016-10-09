module UrlParser exposing
  ( Parser, string, int, s
  , (</>), map, oneOf, top, custom
  , QueryParser, (<?>), stringParam, intParam, customParam
  , parsePath, parseHash
  )

{-|

# Primitives
@docs Parser, string, int, s

# Path Parses
@docs (</>), map, oneOf, top, custom

# Query Parameter Parsers
@docs QueryParser, (<?>), stringParam, intParam, customParam

# Run a Parser
@docs parsePath, parseHash

-}

import Dict exposing (Dict)
import Http
import Navigation
import String



-- PARSERS


{-| Turn URLs like `/blog/42/cat-herding-techniques` into nice Elm data.
-}
type Parser a b =
  Parser (State a -> List (State b))


type alias State value =
  { visited : List String
  , unvisited : List String
  , params : Dict String String
  , value : value
  }



-- PARSE SEGMENTS


string : Parser (String -> a) a
string =
  custom "STRING" Ok


int : Parser (Int -> a) a
int =
  custom "NUMBER" String.toInt


s : String -> Parser a a
s str =
  Parser <| \{ visited, unvisited, params, value } ->
    case unvisited of
      [] ->
        []

      next :: rest ->
        if next == str then
          [ State (next :: visited) rest params value ]

        else
          []


custom : String -> (String -> Result String a) -> Parser (a -> b) b
custom tipe stringToSomething =
  Parser <| \{ visited, unvisited, params, value } ->
    case unvisited of
      [] ->
        []

      next :: rest ->
        case stringToSomething next of
          Ok nextValue ->
            [ State (next :: visited) rest params (value nextValue) ]

          Err msg ->
            []



-- COMBINING PARSERS


infixr 7 </>


(</>) : Parser a b -> Parser b c -> Parser a c
(</>) (Parser parseBefore) (Parser parseAfter) =
  Parser <| \state ->
    List.concatMap parseAfter (parseBefore state)


map : a -> Parser a b -> Parser (b -> c) c
map subValue (Parser parse) =
  Parser <| \{ visited, unvisited, params, value } ->
    List.map (mapHelp value) <| parse <|
      { visited = visited
      , unvisited = unvisited
      , params = params
      , value = subValue
      }


mapHelp : (a -> b) -> State a -> State b
mapHelp func {visited, unvisited, params, value} =
  { visited = visited
  , unvisited = unvisited
  , params = params
  , value = func value
  }


oneOf : List (Parser a b) -> Parser a b
oneOf parsers =
  Parser <| \state ->
    List.concatMap (\(Parser parser) -> parser state) parsers


top : Parser a a
top =
  Parser <| \state -> [state]



-- QUERY PARAMETERS


type QueryParser a b =
  QueryParser (State a -> List (State b))


infixl 8 <?>


(<?>) : Parser a b -> QueryParser b c -> Parser a c
(<?>) (Parser parser) (QueryParser queryParser) =
  Parser <| \state ->
    List.concatMap queryParser (parser state)


stringParam : String -> QueryParser (Maybe String -> a) a
stringParam name =
  customParam name identity


intParam : String -> QueryParser (Maybe Int -> a) a
intParam name =
  customParam name intParamHelp


intParamHelp : Maybe String -> Maybe Int
intParamHelp maybeValue =
  case maybeValue of
    Nothing ->
      Nothing

    Just value ->
      Result.toMaybe (String.toInt value)


customParam : String -> (Maybe String -> a) -> QueryParser (a -> b) b
customParam key func =
  QueryParser <| \{ visited, unvisited, params, value } ->
    [ State visited unvisited params (value (func (Dict.get key params))) ]


-- jsonParam : String -> Decoder a -> QueryParser (Maybe a -> b) b
-- enumParam : String -> Dict String a -> QueryParser (Maybe a -> b) b



-- RUN A PARSER


parsePath : Parser (a -> a) a -> Navigation.Location -> Maybe a
parsePath parser location =
  parse parser location.pathname (parseParams location.search)


parseHash : Parser (a -> a) a -> Navigation.Location -> Maybe a
parseHash parser location =
  parse parser (String.dropLeft 1 location.hash) (parseParams location.search)



-- PARSER HELPERS


parse : Parser (a -> a) a -> String -> Dict String String -> Maybe a
parse (Parser parser) url params =
  parseHelp <| parser <|
    { visited = []
    , unvisited = splitUrl url
    , params = params
    , value = identity
    }


parseHelp : List (State a) -> Maybe a
parseHelp states =
  case states of
    [] ->
      Nothing

    state :: rest ->
      case state.unvisited of
        [] ->
          Just state.value

        [""] ->
          Just state.value

        _ ->
          parseHelp rest


splitUrl : String -> List String
splitUrl url =
  case String.split "/" url of
    "" :: segments ->
      segments

    segments ->
      segments


parseParams : String -> Dict String String
parseParams queryString =
  queryString
    |> String.dropLeft 1
    |> String.split "&"
    |> List.filterMap toKeyValuePair
    |> Dict.fromList


toKeyValuePair : String -> Maybe (String, String)
toKeyValuePair segment =
  case String.split "=" segment of
    [key, value] ->
      Maybe.map2 (,) (Http.decodeUri key) (Http.decodeUri value)

    _ ->
      Nothing