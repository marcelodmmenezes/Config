import XMonad
import Data.Monoid
import System.Exit

import XMonad.Util.Run
import XMonad.Util.SpawnOnce

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog

import XMonad.Layout.Spacing

import XMonad.Actions.FindEmptyWorkspace

import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W
import qualified Data.Map as M

myTerminal = "xterm"

myModMask = mod4Mask

myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False
 
myWorkspaces = [ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]

myBorderWidth = 2
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#00cc00"

---------------
-- KEY BINDINGS
---------------
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $ [
        -- launch dmenu
        ((modm, xK_p), spawn "dmenu_run"),

        -- launch gmrun
        ((modm .|. shiftMask, xK_p), spawn "gmrun"),

        -- close focused window
        ((modm, xK_c), kill),

        -- Rotate through the available layout algorithms
        ((modm, xK_space), sendMessage NextLayout),

        --  Reset the layouts on the current workspace to default
        ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),

        -- Resize viewed windows to the correct size
        ((modm, xK_n), refresh),

        -- Move focus to the next window
        ((modm, xK_Tab), windows W.focusDown),

        -- Move focus to the next window
        ((modm, xK_h), windows W.focusUp),

        -- Move focus to the previous window
        ((modm, xK_l), windows W.focusDown),

        -- Swap the focused window with the next window
        ((modm .|. shiftMask, xK_h), windows W.swapUp),

        -- Swap the focused window with the previous window
        ((modm .|. shiftMask, xK_l), windows W.swapDown),

        -- Move focus to the master window
        ((modm, xK_m), windows W.focusMaster),

        -- Swap the focused window and the master window
        ((modm, xK_Return), windows W.swapMaster),

        -- Shrink the master area
        ((modm .|. shiftMask, xK_comma), sendMessage Shrink),

        -- Expand the master area
        ((modm .|. shiftMask, xK_period), sendMessage Expand),

        -- Push window back into tiling
        ((modm, xK_t), withFocused $ windows . W.sink),

        -- Increment the number of windows in the master area
        ((modm, xK_comma), sendMessage (IncMasterN 1)),

        -- Deincrement the number of windows in the master area
        ((modm, xK_period), sendMessage (IncMasterN (-1))),

        ------------------------------------------------------------------------
        -- Programs
        ((modm, xK_o), spawn $ XMonad.terminal conf),
        ((modm, xK_i), spawn "google-chrome"),
        ((modm, xK_u), spawn "nautilus --new-window"),

        -- Volume keys
        ((0, xF86XK_AudioLowerVolume), spawn "amixer -D pulse sset Master 5%-"),
        ((0, xF86XK_AudioRaiseVolume), spawn "amixer -D pulse sset Master 5%+"),
        ((0, xF86XK_AudioMute), spawn "amixer -D pulse set Master 1+ toggle"),

        -- Switch to empty workspace
        ((modm, xK_d), viewEmptyWorkspace),
        ------------------------------------------------------------------------

        -- Quit xmonad
        ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess)),

        -- Restart xmonad
        ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart"),

        -- Run xmessage with a summary of the default keybindings (useful for beginners)
        ((modm .|. shiftMask, xK_slash), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]

    ++

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

    ++

    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-----------------
-- MOUSE BINDINGS
-----------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $ [
        -- mod-button1, Set the window to floating mode and move by dragging
        ((modm, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)),

        -- mod-button2, Raise the window to the top of the stack
        ((modm, button2), (\w -> focus w >> windows W.shiftMaster)),

        -- mod-button3, Set the window to floating mode and resize by dragging
        ((modm, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
    ]

----------
-- LAYOUTS
----------
mySpacing = spacingRaw True
    (Border 0 15 10 10)
	True
	(Border 5 5 5 5)
	True

myLayout = mySpacing $ avoidStruts (tiled ||| Mirror tiled ||| Full)
    where
        -- default tiling algorithm partitions the screen into two panes
        tiled = Tall nmaster delta ratio

        -- The default number of windows in the master pane
        nmaster = 1

        -- Default proportion of screen occupied by master pane
        ratio = 1/2

        -- Percent of screen to increment by when resizing panes
        delta = 3/100

---------------
-- WINDOW RULES
---------------
myManageHook = composeAll [
        className =? "MPlayer" --> doFloat,
        className =? "Gimp" --> doFloat,
        className =? "Blender" --> doFloat,
        resource  =? "desktop_window" --> doIgnore,
        resource  =? "kdesktop" --> doIgnore
    ]

-----------------
-- EVENT HANDLING
-----------------
myEventHook = mempty

---------------
-- STARTUP HOOK
---------------
myStartupHook = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "compton &"

-------
-- MAIN
-------
windowCount :: X(Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

main :: IO()
main = do
    xmproc0 <- spawnPipe "xmobar -x 0 ~/.xmobar0rc"
    xmproc1 <- spawnPipe "xmobar -x 1 ~/.xmobar1rc"

    xmonad $ docks def {
        -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

        -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

        -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,

        startupHook = myStartupHook,

        logHook = dynamicLogWithPP xmobarPP {
            ppOutput = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x,
            ppCurrent = xmobarColor "#00cc00" "" . wrap "[" "]",
            ppVisible = xmobarColor "#6688cc" "",
            ppHidden = xmobarColor "#cc6666" "" . wrap "*" "",
            ppHiddenNoWindows = xmobarColor "#cccccc" "",
            ppTitle = xmobarColor "#00cc00" "" . shorten 20,
            ppSep = "<fc=#ff0000> | </fc>",
            ppExtras = [windowCount],
            ppOrder = \(ws:l:t:ex) -> [ws, l] ++ ex ++ [t]
        }
    }

-------
-- HELP
-------
help :: String
help = unlines [
        "The default modifier key is 'alt'. Default keybindings:",
        "",
        "-- launching and killing programs",
        "mod-Shift-Enter  Launch xterminal",
        "mod-p            Launch dmenu",
        "mod-Shift-p      Launch gmrun",
        "mod-Shift-c      Close/kill the focused window",
        "mod-Space        Rotate through the available layout algorithms",
        "mod-Shift-Space  Reset the layouts on the current workSpace to default",
        "mod-n            Resize/refresh viewed windows to the correct size",
        "",
        "-- move focus up or down the window stack",
        "mod-Tab        Move focus to the next window",
        "mod-Shift-Tab  Move focus to the previous window",
        "mod-j          Move focus to the next window",
        "mod-k          Move focus to the previous window",
        "mod-m          Move focus to the master window",
        "",
        "-- modifying the window order",
        "mod-Return   Swap the focused window and the master window",
        "mod-Shift-j  Swap the focused window with the next window",
        "mod-Shift-k  Swap the focused window with the previous window",
        "",
        "-- resizing the master/slave ratio",
        "mod-h  Shrink the master area",
        "mod-l  Expand the master area",
        "",
        "-- floating layer support",
        "mod-t  Push window back into tiling; unfloat and re-tile it",
        "",
        "-- increase or decrease number of windows in the master area",
        "mod-comma  (mod-,)   Increment the number of windows in the master area",
        "mod-period (mod-.)   Deincrement the number of windows in the master area",
        "",
        "-- quit, or restart",
        "mod-Shift-q  Quit xmonad",
        "mod-q        Restart xmonad",
        "mod-[1..9]   Switch to workSpace N",
        "",
        "-- Workspaces & screens",
        "mod-Shift-[1..9]   Move client to workspace N",
        "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
        "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
        "",
        "-- Mouse bindings: default actions bound to mouse events",
        "mod-button1  Set the window to floating mode and move by dragging",
        "mod-button2  Raise the window to the top of the stack",
        "mod-button3  Set the window to floating mode and resize by dragging"
    ]

