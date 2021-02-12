{ colors }:

''
  -- fortuneteller2k's XMonad config
  -- This file is managed by NixOS, don't edit it directly!

  import Data.Char
  import Data.Monoid

  import System.IO
  import System.Exit

  import XMonad

  import XMonad.Actions.CycleWS
  import XMonad.Actions.Sift
  import XMonad.Actions.TiledWindowDragging
  import XMonad.Actions.WithAll

  import XMonad.Hooks.DynamicLog
  import XMonad.Hooks.EwmhDesktops
  import XMonad.Hooks.InsertPosition
  import XMonad.Hooks.ManageDocks
  import XMonad.Hooks.ManageHelpers
  import XMonad.Hooks.Place
  import XMonad.Hooks.WindowSwallowing

  import XMonad.Layout.DraggingVisualizer
  import XMonad.Layout.Grid
  import XMonad.Layout.LayoutHints
  import XMonad.Layout.Maximize
  import XMonad.Layout.NoBorders
  import XMonad.Layout.Renamed
  import XMonad.Layout.ResizableThreeColumns
  import XMonad.Layout.ResizableTile
  import XMonad.Layout.Spacing

  import XMonad.Prompt
  import XMonad.Prompt.FuzzyMatch
  import XMonad.Prompt.Shell

  import XMonad.Util.Cursor
  import XMonad.Util.EZConfig
  import XMonad.Util.NamedScratchpad
  import XMonad.Util.Run
  import XMonad.Util.SpawnOnce

  import qualified Codec.Binary.UTF8.String as UTF8
  import qualified Data.Map                 as M
  import qualified DBus                     as D
  import qualified DBus.Client              as D
  import qualified XMonad.Util.Hacks        as Hacks
  import qualified XMonad.StackSet          as W

  -- defaults
  modkey = mod1Mask
  term = "alacritty"
  ws = ["A","B","C","D","E","F","G","H","I","J"]
  fontFamily = "xft:FantasqueSansMono Nerd Font:size=10:antialias=true:hinting=true"

  keybindings =
    [ ("M-<Return>",                 safeSpawnProg term)
    , ("M-b",                        namedScratchpadAction scratchpads "terminal")
    , ("M-`",                        distractionLess)
    , ("M-d",                        shellPrompt promptConfig)
    , ("M-q",                        kill)
    , ("M-w",                        safeSpawnProg "emacs")
    , ("M-<F2>",                     unsafeSpawn browser)
    , ("M-e",                        withFocused (sendMessage . maximizeRestore))
    , ("M-<Tab>",                    sendMessage NextLayout)
    , ("M-n",                        refresh)
    , ("M-s",                        windows W.swapMaster)
    , ("M--",                        sendMessage Shrink)
    , ("M-=",                        sendMessage Expand)
    , ("M-[",                        sendMessage MirrorShrink)
    , ("M-]",                        sendMessage MirrorExpand)
    , ("M-t",                        withFocused toggleFloat)
    , ("M-,",                        sendMessage (IncMasterN 1))
    , ("M-.",                        sendMessage (IncMasterN (-1)))
    , ("C-<Left>",                   prevWS)
    , ("C-<Right>",                  nextWS)
    , ("<Print>",                    safeSpawn "/etc/nixos/scripts/screenshot" ["wind"])
    , ("M-<Print>",                  safeSpawn "/etc/nixos/scripts/screenshot" ["area"])
    , ("M-S-s",                      safeSpawn "/etc/nixos/scripts/screenshot" ["full"])
    , ("M-S-q",                      io (exitWith ExitSuccess))
    , ("M-C-c",                      killAll)
    , ("M-S-<Delete>",               safeSpawnProg "slock")
    , ("M-S-c",                      withFocused $ \w -> safeSpawn "xkill" ["-id", show w])
    , ("M-S-r",                      sequence_ [unsafeSpawn restartcmd, unsafeSpawn restackcmd])
    , ("M-S-<Left>",                 shiftToPrev >> prevWS)
    , ("M-S-<Right>",                shiftToNext >> nextWS)
    , ("M-<Left>",                   windows W.focusUp)
    , ("M-<Right>",                  windows W.focusDown)
    , ("M-S-<Tab>",                  sendMessage FirstLayout)
    , ("<XF86AudioMute>",            safeSpawn "/etc/nixos/scripts/volume" ["toggle"])
    , ("<XF86AudioRaiseVolume>",     safeSpawn "/etc/nixos/scripts/volume" ["up"])
    , ("<XF86AudioLowerVolume>",     safeSpawn "/etc/nixos/scripts/volume" ["down"])
    , ("<XF86AudioPlay>",            safeSpawn "mpc" ["toggle"])
    , ("<XF86AudioPrev>",            safeSpawn "mpc" ["prev"])
    , ("<XF86AudioNext>",            safeSpawn "mpc" ["next"])
    , ("<XF86MonBrightnessUp>",      safeSpawn "brightnessctl" ["s", "+10%"])
    , ("<XF86MonBrightnessDown>",    safeSpawn "brightnessctl" ["s", "10%-"])
    ]
    ++
    [ (otherModMasks ++ "M-" ++ key, action tag)
        | (tag, key) <- zip ws (map show ([1..9] ++ [0]))
        , (otherModMasks, action) <- [ ("", windows . W.greedyView)
                                     , ("S-", windows . W.shift) ] ]
    where 
      distractionLess = sequence_ [unsafeSpawn restackcmd, sendMessage ToggleStruts, toggleScreenSpacingEnabled, toggleWindowSpacingEnabled]
      restartcmd = "xmonad --restart && systemctl --user restart polybar"
      restackcmd = "sleep 1.2; xdo lower $(xwininfo -name polybar-xmonad | rg 'Window id' | cut -d ' ' -f4)"
      browser = concat
        [ "qutebrowser"
        , " --qt-flag ignore-gpu-blacklist"
        , " --qt-flag enable-gpu-rasterization"
        , " --qt-flag enable-native-gpu-memory-buffers"
        , " --qt-flag num-raster-threads=4"
        , " --qt-flag enable-oop-rasterization" ]
      toggleFloat w = windows (\s -> if M.member w (W.floating s)
                                      then W.sink w s
                                      else (W.float w (W.RationalRect 0.15 0.15 0.7 0.7) s))

  mousebindings = 
    [ ((modkey .|. shiftMask, button1), dragWindow)
    , ((modkey, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
    , ((modkey, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modkey, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)) ]

  scratchpads = [ NS "terminal" (term ++ " -t ScratchpadTerm") (title =? "ScratchpadTerm") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ]

  promptConfig = def
    { font                = fontFamily
    , bgColor             = "#${colors.bg}"
    , fgColor             = "#${colors.fg}"
    , bgHLight            = "#${colors.highlightColor}"
    , fgHLight            = "#${colors.bg}"
    , promptBorderWidth   = 0
    , position            = Top
    , height              = 20
    , historySize         = 256
    , historyFilter       = id
    , showCompletionOnTab = False
    , searchPredicate     = fuzzyMatch
    , sorter              = fuzzySort
    , defaultPrompter     = \_ -> "xmonad λ: "
    , alwaysHighlight     = True
    , maxComplRows        = Just 5
    }

  layouts = avoidStruts 
            $ renamed [CutWordsLeft 4]
            $ spacingRaw False (Border 4 4 4 4) True (Border 4 4 4 4) True
            $ draggingVisualizer
            $ layoutHints
            $ maximizeWithPadding 0
            $ smartBorders 
            $ (tall ||| Mirror tall ||| threecol ||| Grid)
    where
      tall = ResizableTall 1 (3/100) (11/20) []
      threecol = ResizableThreeColMid 1 (3/100) (1/2) []

  windowRules =
    placeHook (smart (0.5, 0.5))
    <+> namedScratchpadManageHook scratchpads
    <+> composeAll
    [ className  =? "Gimp"                                 --> doFloat
    , (className =? "Ripcord" <&&> title =? "Preferences") --> doFloat
    , className  =? "Xmessage"                             --> doFloat
    , className  =? "Peek"                                 --> doFloat
    , className  =? "Xephyr"                               --> doFloat
    , className  =? "Sxiv"                                 --> doFloat
    , className  =? "mpv"                                  --> doFloat
    , appName    =? "desktop_window"                       --> doIgnore
    , appName    =? "kdesktop"                             --> doIgnore
    , isDialog                                             --> doF siftUp <+> doFloat ]
    <+> insertPosition End Newer -- same effect as attachaside patch in dwm
    <+> manageDocks
    <+> manageHook defaultConfig

  autostart = do
    setDefaultCursor xC_left_ptr
    spawnOnce "systemctl --user restart polybar &"
    spawnOnce "xwallpaper --zoom .config/nix-config/nixos/config/wallpapers/horizonblurgradient.png &"
    spawnOnce "xidlehook --not-when-fullscreen --not-when-audio --timer 120 slock \'\' &"
    spawnOnce "notify-desktop -u low 'xmonad' 'started successfully'"

  barHook dbus = dynamicLogWithPP $ xmobarPP
    { ppOutput = dbusOutput dbus
    , ppOrder  = \(_:l:_:_) -> [l]
    }
    where
      dbusOutput dbus str =
        let
          opath  = D.objectPath_ "/org/xmonad/Log"
          iname  = D.interfaceName_ "org.xmonad.Log"
          mname  = D.memberName_ "Update"
          signal = D.signal opath iname mname
          body   = [D.toVariant $ UTF8.decodeString str]
        in
          D.emit dbus $ signal { D.signalBody = body }

  main' dbus = xmonad . ewmhFullscreen . docks . ewmh . Hacks.javaHack $ def
    { focusFollowsMouse  = True
    , clickJustFocuses   = True
    , borderWidth        = 2
    , modMask            = modkey
    , workspaces         = ws
    , normalBorderColor  = "#${colors.inactiveBorderColor}"
    , focusedBorderColor = "#${colors.activeBorderColor}"
    , layoutHook         = layouts
    , manageHook         = windowRules
    , logHook            = barHook dbus
    , handleEventHook    = hintsEventHook <+> swallowEventHook (return True) (return True)
    , startupHook        = autostart
    } 
    `additionalKeysP` keybindings
    `additionalMouseBindings` mousebindings

  main = dbusClient >>= main' -- "that was easy, xmonad rocks!"
    where
      dbusClient = do
        dbus <- D.connectSession
        D.requestName dbus (D.busName_ "org.xmonad.log") [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
        return dbus
''
