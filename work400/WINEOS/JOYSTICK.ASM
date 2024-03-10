js          DIJOYSTATE <>



_Detect_Joystick:
            pushad
            CCALL UpdateInputStateJoystick,<O js>
            cmp eax,-1
            popad
            je @@Error
            mov eax,O js
            clc
            ret
@@Error:
            xor eax,eax
            stc
            ret

_UpDate_Joystick:
            pushad
            CCALL UpdateInputStateJoystick,<O js>
            popad
            ret