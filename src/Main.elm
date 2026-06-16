port module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Regex

main : Program () Model Msg
main = 
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }

-- Model

init : () -> (Model, Cmd Msg)
init () =
    ({ phrase = "", mimyfiedPhrase = "" }, Cmd.none
    )

type alias Model =
    { phrase: String
      , mimyfiedPhrase: String
    }

type MimyfyError =
    String

type Msg
    = UpdatePhrase String
    | MimifyPhrase
    | CopyToClipboard

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UpdatePhrase result ->
            ({ model | phrase = result }, Cmd.none)
        MimifyPhrase ->
            ({ model | mimyfiedPhrase = mimify model.phrase }, Cmd.none)
        CopyToClipboard ->
            (model, copyToClipboard model.mimyfiedPhrase)

-- CMD
replaceVowel : String -> (Regex.Match -> String) -> String -> String
replaceVowel vowelRegex replacer string =
    case Regex.fromString vowelRegex of
        Nothing ->
            string
        Just regex ->
            Regex.replace regex replacer string

mimify : String -> String
mimify userPhrase =
    replaceVowel "[aeiouAEIOU]" (\_ -> "i") userPhrase

-- PORTS
{-| Outbound port, Elm -> JS
-}
port copyToClipboard : String -> Cmd msg

-- VIEW

view : Model -> Html Msg
view model =
    Html.div []
        [ Html.header [] [ Html.h1 [] [ Html.text "Mimify" ] ]
        , Html.main_ []
            [Html.form
                [ Events.onSubmit MimifyPhrase]
                [ Html.input
                    [ Attributes.type_ "text"
                      , Attributes.value model.phrase
                      , Attributes.placeholder "Enter a phrase"
                      , Attributes.size 50
                      , Events.onInput UpdatePhrase
                    ]
                    []
                , Html.button [ Attributes.type_ "submit" ] [ Html.text "Mimify!" ]
                ]
            , Html.span [ Events.onClick CopyToClipboard, Attributes.style "cursor" "pointer" ] [ Html.text model.mimyfiedPhrase ]
            ]
        ]