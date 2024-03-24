module Model.Game exposing (Game, init, player, mapPlayer, movePlayer, court, mapCourt, endGame, gameOverか, winner)

import Model.Ball as Ball exposing (Ball)
import Model.Paddle as Paddle exposing (Paddle)
import Model.Court as Court exposing (Court, Side(..))
import Model.Player as Player exposing (Player)
import Duration
import Quantity 
import Pixels
import Units.Pong as Units
import Length
import Direction2d

{- Game is a container structure for players and the game world -}

-- Model for game logic that handles two players and a court
type Game 
    = Game Player Player Court
    | Winner Side Player Player Court

init : Game
init =
    Game
        Player.init
        Player.init
        Court.init

player : Side -> Game -> Player
player s g =
    case (s,g) of
        (Left, Game l _ _) -> l
        (Right, Game _ r _) -> r
        (Left, Winner _ l _ _) -> l
        (Right, Winner _ _ r _) -> r

court : Game -> Court
court g =
    case g of
        Game _ _ c -> c
        Winner _ _ _ c -> c

mapPlayer : Side -> (Player -> Player) -> Game -> Game
mapPlayer s f g =
    case (s, g) of
        (Left, Game l r c) -> Game (f l) r c
        (Right, Game l r c) -> Game l (f r) c
        _ -> g

mapCourt : (Court -> Court) -> Game -> Game
mapCourt f g =
    case g of
        Game l r c -> Game l r (f c)
        Winner s l r c -> Winner s l r (f c)

movePlayer : Side -> Player.Impulse -> Game -> Game
movePlayer s i =
    mapPlayer s (Player.move i)

endGame : Side -> Game -> Game
endGame s g =
    let
        l = player Left g
        r = player Right g
        c = court g
    in
    Winner s l r c

gameOverか : Game -> Bool
gameOverか g =
    case g of
        Winner _ _ _ _ -> True
        _ -> False

winner : Game -> Maybe Side
winner g =
    case g of
        Winner s _ _ _ -> Just s
        _ -> Nothing
