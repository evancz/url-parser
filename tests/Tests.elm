module Tests exposing (..)

import UrlParser exposing (..)
import Navigation exposing (Location)
import Test exposing (..)
import Expect



-- TESTS


all : Test
all =
    describe "UrlParser"
        [ describe "Basic Parsing" testParsing
        ]


testParsing =
    [ parserTest "Home" "" HomeRoute
    , parserTest "About" "about" AboutRoute
    , parserTest "Token" "token/abc" (TokenRoute "abc")
    , parserTest "Users" "users" (UsersRoutes UsersRoute)
    , parserTest "User" "users/2" (UsersRoutes (UserRoute 2))
    , parserTest "Edit" "users/2/edit" (UsersRoutes (UserEditRoute 2))
    ]


parserTest name path expectedRoute =
    describe name
        [ test (name ++ " in path") <|
            \() ->
                Expect.equal
                    (Just expectedRoute)
                    (parsePath routeParser { newLocation | pathname = "/" ++ path })
        , test (name ++ " in hash") <|
            \() ->
                Expect.equal
                    (Just expectedRoute)
                    (parseHash routeParser { newLocation | hash = "#/" ++ path })
        , test (name ++ "in hash without leading slash") <|
            \() ->
                Expect.equal
                    (Just expectedRoute)
                    (parseHash routeParser { newLocation | hash = "#" ++ path })
        ]



-- ROUTES


type alias UserId =
    Int


type UserRoute
    = UsersRoute
    | UserRoute UserId
    | UserEditRoute UserId


type MainRoute
    = HomeRoute
    | AboutRoute
    | TokenRoute String
    | UsersRoutes UserRoute
    | NotFoundRoute



-- PARSERS


routeParser =
    oneOf mainMatchers


usersMatchers =
    [ map UserEditRoute (int </> s "edit")
    , map UserRoute (int)
    , map UsersRoute top
    ]


mainMatchers =
    [ map HomeRoute top
    , map AboutRoute (s "about")
    , map TokenRoute (s "token" </> string)
    , map UsersRoutes (s "users" </> (oneOf usersMatchers))
    ]



-- DUMMY LOCATION


newLocation : Location
newLocation =
    { hash = ""
    , host = "example.com"
    , hostname = "example.com"
    , href = ""
    , origin = ""
    , password = ""
    , pathname = ""
    , port_ = ""
    , protocol = "http"
    , search = ""
    , username = ""
    }
