port module Msg.Ports exposing (..)

port initializeAudioContext : () -> Cmd msg

port playPaddleBounceSFX : () -> Cmd msg

port playWallBounceSFX : () -> Cmd msg

port playGoalScoreSFX : () -> Cmd msg

port playGameOverSFX : () -> Cmd msg
