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
    Html.div [ Attributes.class "wrapper" ]
        [ Html.header [ Attributes.class "header-wrapper" ] 
            [ Html.h1 
                [ Attributes.style "width" "fit-content"
                  , Attributes.style "margin-left" "auto"
                  , Attributes.style "margin-right" "auto"
                  , Attributes.style "margin-bottom" "1rem"
                  , Attributes.style "font-size" "3rem"
                  , Attributes.style "font-style" "normal"
                ]
                [ Html.text "Mimify" ]
            ]
        , Html.section
            [ Attributes.class "card"
            ] 
            [ Html.article
                []
                [  Html.h1 [ Attributes.class "article-title" ]
                    [ Html.text "✏️ Escribe una frase" ]
                  , Html.form
                    [ Attributes.class "form"
                    , Events.onSubmit MimifyPhrase
                    ]
                    [ Html.textarea
                        [ Attributes.class "textarea"
                        , Attributes.value model.phrase
                        , Attributes.placeholder "Escribe aquí cualquier frase..."
                        , Attributes.rows 5
                        , Attributes.cols 50
                        , Attributes.maxlength 200
                        , Events.onInput UpdatePhrase
                        ]
                        []
                    , Html.button [ 
                        Attributes.class "mimify-button"
                        , Attributes.type_ "submit" ] [ Html.text "✨ Mimificar" ]
                    ]
                ]
                , Html.article
                    [ Attributes.class "card"
                    ]
                    [
                        Html.h1 [ Attributes.class "article-title" ]
                            [ Html.text "😊 Resultado" ]
                        , Html.div [ Attributes.class "result-box" ]
                            [
                                Html.span []
                                [ Html.text model.mimyfiedPhrase ]
                            ]
                        , Html.button
                            [ Attributes.class "copy-button"
                            , Events.onClick CopyToClipboard
                            ]
                            [ Html.text "📋 Copiar" ]
                    ]
            ]
        ]