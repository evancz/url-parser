module Tests exposing (..)

import UrlParser exposing (..)
import Navigation exposing (Location)
import Test exposing (..)
import Expect
import String


type Kind
    = Path
    | Hash


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


matchers =
    oneOf mainMatchers


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


matchersTest : Test
matchersTest =
    let
        inputs =
            [ ( "Home page in pathname"
              , Path
              , "/"
              , Just HomeRoute
              )
            , ( "Home page in hash"
              , Hash
              , "#/"
              , Just HomeRoute
              )
            , ( "Home page in hash"
              , Hash
              , ""
              , Just HomeRoute
              )
            , ( "About page in pathname"
              , Path
              , "/about"
              , Just AboutRoute
              )
            , ( "About page in hash"
              , Hash
              , "#/about"
              , Just AboutRoute
              )
            , ( "Token page in pathname"
              , Path
              , "/token/abc"
              , Just (TokenRoute "abc")
              )
            , ( "Token page in hash"
              , Hash
              , "#/token/abc"
              , Just (TokenRoute "abc")
              )
            , ( "Users in pathname"
              , Path
              , "/users"
              , Just (UsersRoutes UsersRoute)
              )
            , ( "Users in hash"
              , Hash
              , "#/users"
              , Just (UsersRoutes UsersRoute)
              )
            , ( "User in pathname"
              , Path
              , "/users/2"
              , Just (UsersRoutes (UserRoute 2))
              )
            , ( "User in hash"
              , Hash
              , "#/users/2"
              , Just (UsersRoutes (UserRoute 2))
              )
            , ( "User Edit in pathname"
              , Path
              , "/users/2/edit"
              , Just (UsersRoutes (UserEditRoute 2))
              )
            , ( "User Edit in hash"
              , Hash
              , "#/users/2/edit"
              , Just (UsersRoutes (UserEditRoute 2))
              )
            ]

        run ( testCase, kind, path, expectedRoute ) =
            test testCase
                <| \() ->
                    let
                        location =
                            case kind of
                                Path ->
                                    { newLocation | pathname = path }

                                Hash ->
                                    { newLocation | hash = path }

                        actualRoute =
                            case kind of
                                Path ->
                                    parsePath matchers location

                                Hash ->
                                    parseHash matchers location
                    in
                        Expect.equal expectedRoute actualRoute
    in
        describe "Matchers" (List.map run inputs)


all : Test
all =
    describe "UrlParser"
        [ matchersTest ]
