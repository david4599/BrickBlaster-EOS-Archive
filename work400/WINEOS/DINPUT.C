#include <wineos.h>
#define BUFFER_SIZE 32
#define c_dfDIKeyboard _c_dfDIKeyboard
#define c_dfDIJoystick _c_dfDIJoystick
#define c_dfDIMouse _c_dfDIMouse

  extern const DIDATAFORMAT _c_dfDIMouse;
  extern const DIDATAFORMAT _c_dfDIKeyboard;
  extern const DIDATAFORMAT _c_dfDIJoystick;
  static  IDirectInput*           g_pDI               = NULL;
  static  IDirectInputDevice*     g_pMouse            = NULL;
  static  IDirectInputDevice*     g_pKeyboard         = NULL;
  static  IDirectInputDevice*     g_pJoystick         = NULL;
  static  IDirectInputDevice2*    g_pJoystickDevice2  = NULL;  // needed to poll joystick

//-----------------------------------------------------------------------------
// Function: EnumJoysticksCallback
//
// Description:
//      Called once for each enumerated joystick. If we find one,
//       create a device interface on it so we can play with it.
//
//-----------------------------------------------------------------------------
BOOL CALLBACK EnumJoysticksCallback( LPCDIDEVICEINSTANCE pInst,LPVOID lpvContext )
{
    HRESULT             hr;
    LPDIRECTINPUTDEVICE pDevice;

    // obtain an interface to the enumerated force feedback joystick.
    hr = IDirectInput_CreateDevice(g_pDI,&pInst->guidInstance, &pDevice, NULL );

    // if it failed, then we can't use this joystick for some
    // bizarre reason.  (Maybe the user unplugged it while we
    // were in the middle of enumerating it.)  So continue enumerating
    if ( FAILED(hr) )
        return DIENUM_CONTINUE;

    // we successfully created an IDirectInputDevice.  So stop looking
    // for another one.
    g_pJoystick = pDevice;

    // query for IDirectInputDevice2 - we need this to poll the joystick
    IDirectInputDevice2_QueryInterface( pDevice,&IID_IDirectInputDevice2,(LPVOID *)&g_pJoystickDevice2 );

    return DIENUM_STOP;
}


//-----------------------------------------------------------------------------
// Function: InitDirectInput
//
// Description:
//      Initialize the DirectInput variables.
//
//-----------------------------------------------------------------------------
HRESULT __cdecl InitDirectInput(HINSTANCE hInst,HWND hWnd )
{
    HRESULT hr;
    DIPROPRANGE diprg;           // set the range of the joystick axis
    DIPROPDWORD dipdw;


    // Register with the DirectInput subsystem and get a pointer
    // to a IDirectInput interface we can use.
    hr = DirectInputCreate( hInst, DIRECTINPUT_VERSION, &g_pDI, NULL );
    if ( FAILED(hr) )
        return hr;

    // Obtain an interface to the system mouse device.
    hr = IDirectInput_CreateDevice( g_pDI,&GUID_SysMouse, &g_pMouse, NULL );
    if ( FAILED(hr) )
        return hr;

    // Set the data format to "mouse format" - a predefined data format
    //
    // A data format specifies which controls on a device we
    // are interested in, and how they should be reported.
    //
    // This tells DirectInput that we will be passing a
    // DIMOUSESTATE structure to IDirectInputDevice::GetDeviceState.
    hr = IDirectInputDevice_SetDataFormat(g_pMouse, &c_dfDIMouse );
    if ( FAILED(hr) )
        return hr;

    // Set the cooperativity level to let DirectInput know how
    // this device should interact with the system and with other
    // DirectInput applications.
    hr = IDirectInputDevice_SetCooperativeLevel(g_pMouse,hWnd,
                                        DISCL_EXCLUSIVE | DISCL_FOREGROUND);
//                                        DISCL_NONEXCLUSIVE | DISCL_FOREGROUND);
    if ( FAILED(hr) )
        return hr;

    // Obtain an interface to the system keyboard device.
    hr = IDirectInput_CreateDevice( g_pDI,&GUID_SysKeyboard, &g_pKeyboard, NULL );
    if ( FAILED(hr) )
        return hr;

    // Set the data format to "keyboard format" - a predefined data format
    //
    // A data format specifies which controls on a device we
    // are interested in, and how they should be reported.
    //
    // This tells DirectInput that we will be passing an array
    // of 256 bytes to IDirectInputDevice::GetDeviceState.
    hr = IDirectInputDevice_SetDataFormat(g_pKeyboard, &c_dfDIKeyboard );
    if ( FAILED(hr) )
        return hr;

    // Set the cooperativity level to let DirectInput know how
    // this device should interact with the system and with other
    // DirectInput applications.
    hr = IDirectInputDevice_SetCooperativeLevel(g_pKeyboard, hWnd,
                                        DISCL_EXCLUSIVE | DISCL_FOREGROUND);
//                                        DISCL_NONEXCLUSIVE | DISCL_FOREGROUND);


    dipdw.diph.dwSize = sizeof(DIPROPDWORD);
    dipdw.diph.dwHeaderSize = sizeof(DIPROPHEADER);
    dipdw.diph.dwObj = 0;
    dipdw.diph.dwHow = DIPH_DEVICE;
    dipdw.dwData = BUFFER_SIZE;

    IDirectInputDevice_SetProperty(g_pKeyboard ,DIPROP_BUFFERSIZE, &dipdw.diph );


    // look for a simple joystick we can use for this sample program.
    hr = IDirectInput_EnumDevices(g_pDI,DIDEVTYPE_JOYSTICK,EnumJoysticksCallback,NULL,DIEDFL_ATTACHEDONLY);
    if ( FAILED(hr) )
        return hr;

    if (g_pJoystick == NULL)  // No Joystick Connected
        return S_OK;

    // Set the data format to "simple joystick" - a predefined data format
    //
    // A data format specifies which controls on a device we
    // are interested in, and how they should be reported.
    //
    // This tells DirectInput that we will be passing a
    // DIJOYSTATE structure to IDirectInputDevice::GetDeviceState.
    hr = IDirectInputDevice_SetDataFormat(g_pJoystick, &c_dfDIJoystick );
    if ( FAILED(hr) )
        return hr;

    // Set the cooperativity level to let DirectInput know how
    // this device should interact with the system and with other
    // DirectInput applications.
    hr = IDirectInputDevice_SetCooperativeLevel(g_pJoystick, hWnd,DISCL_EXCLUSIVE | DISCL_FOREGROUND);
    if ( FAILED(hr) )
        return hr;


    diprg.diph.dwSize       = sizeof(DIPROPRANGE);
    diprg.diph.dwHeaderSize = sizeof(DIPROPHEADER);
    diprg.diph.dwHow        = DIPH_BYOFFSET;
    diprg.lMin              = -1000;
    diprg.lMax              = +1000;

    diprg.diph.dwObj = DIJOFS_X;    // set the x-axis range
    hr = IDirectInputDevice_SetProperty(g_pJoystick, DIPROP_RANGE, &diprg.diph );
    if ( FAILED(hr) )
        return hr;

    diprg.diph.dwObj = DIJOFS_Y;    // set the y-axis range
    hr = IDirectInputDevice_SetProperty(g_pJoystick, DIPROP_RANGE, &diprg.diph );
    if ( FAILED(hr) )
        return hr;
/*
    diprg.diph.dwObj = DIJOFS_Z;    // set the z-axis range
    hr = IDirectInputDevice_SetProperty(g_pJoystick, DIPROP_RANGE, &diprg.diph );
    if ( FAILED(hr) )
        return hr;

    diprg.diph.dwObj = DIJOFS_RZ;   // set the rudder range
    hr = IDirectInputDevice_SetProperty(g_pJoystick, DIPROP_RANGE, &diprg.diph );
    if ( FAILED(hr) )
        return hr;
*/

/*    ZeroMem(&dipdw,sizeof(DIPROPDWORD));

    dipdw.diph.dwSize       = sizeof(DIPROPDWORD);
    dipdw.diph.dwHeaderSize = sizeof(DIPROPHEADER);
    dipdw.diph.dwObj        = 0; // device property
    dipdw.diph.dwHow        = DIPH_DEVICE;
    hr = IDirectInputDevice_GetProperty(g_pJoystick,DIPROP_DEADZONE  ,&dipdw.diph);
    if ( FAILED(hr) )
        return hr;
    break_point();
    dipdw.dwData        = 10; // device property
*/

    return S_OK;
}

//-----------------------------------------------------------------------------
// Function: SetAcquire
//
// Description:
//      Acquire or unacquire the mouse, depending on if the app is active
//       Input device must be acquired before the GetDeviceState is called
//
//-----------------------------------------------------------------------------
HRESULT __cdecl SetAcquireInput( HWND hWnd,BOOL bActive )
{
    // nothing to do if g_pMouse is NULL
    if (NULL == g_pMouse)
        return S_FALSE;

    if (bActive)
    {
        // acquire the input device
        IDirectInputDevice_Acquire(g_pMouse);
        IDirectInputDevice_Acquire(g_pKeyboard);
        if (g_pJoystick!=NULL )
          IDirectInputDevice_Acquire(g_pJoystick);
    }
    else
    {
        // unacquire the input device
        IDirectInputDevice_Unacquire(g_pMouse);
        IDirectInputDevice_Unacquire(g_pKeyboard);
        if (g_pJoystick!=NULL )
          IDirectInputDevice_Unacquire(g_pJoystick);
    }
    return S_OK;
}

//-----------------------------------------------------------------------------
// Function: UpdateInputState
//
// Description:
//      Get the mouse input device's state.
//
//-----------------------------------------------------------------------------
HRESULT __cdecl UpdateInputStateMouse(DIMOUSESTATE *dims)
{
    HRESULT hr;

    if (NULL != g_pMouse)
    {
        hr = DIERR_INPUTLOST;

        // if input is lost then acquire and keep trying
        while ( DIERR_INPUTLOST == hr )
        {
            // get the input's device state, and put the state in dims
            hr = IDirectInputDevice_GetDeviceState(g_pMouse, sizeof(DIMOUSESTATE), dims );

            if ( hr == DIERR_INPUTLOST )
            {
                // DirectInput is telling us that the input stream has
                // been interrupted.  We aren't tracking any state
                // between polls, so we don't have any special reset
                // that needs to be done.  We just re-acquire and
                // try again.
                hr = IDirectInputDevice_Acquire(g_pMouse);
                if ( FAILED(hr) )
                    return hr;
            }
        }

        if ( FAILED(hr) )
            return hr;
    }

    return S_OK;
}

//-----------------------------------------------------------------------------
// Function: UpdateInputState
//
// Description:
//      Get the keyboard input device's state.
//
//-----------------------------------------------------------------------------
HRESULT __cdecl UpdateInputStateKeyboard(unsigned char *diks) // DirectInput keyboard state buffer
{
    DIDEVICEOBJECTDATA didod[ BUFFER_SIZE ];  // Receives buffered data
    DWORD dwElements;
    long i;

    if (NULL != g_pKeyboard)
    {
        HRESULT hr;

        hr = DIERR_INPUTLOST;

        // if input is lost then acquire and keep trying
        while ( DIERR_INPUTLOST == hr )
        {
            dwElements=BUFFER_SIZE;
            // get the input's device state, and put the state in dims
            hr = IDirectInputDevice_GetDeviceData(g_pKeyboard,sizeof(DIDEVICEOBJECTDATA),didod,&dwElements,0);

            if ( hr == DIERR_INPUTLOST )
            {
                // DirectInput is telling us that the input stream has
                // been interrupted.  We aren't tracking any state
                // between polls, so we don't have any special reset
                // that needs to be done.  We just re-acquire and
                // try again.
                hr = IDirectInputDevice_Acquire(g_pKeyboard);
                if ( FAILED(hr) )
                    return hr;
            }
        }
        for (i=0;i<dwElements;i++)
        {
          diks[(didod[ i ].dwOfs & 0x7f)]=((didod[ i ].dwData & 0x80) ? 1 : 0);
          if ( (i==(dwElements-1)) && ((didod[ i ].dwData & 0x80)==0x80))
          {
            diks[0]=(didod[i].dwOfs & 0x7f);
          }
        }
/*        for (i = 0; i < 128; i++)
          if (diks[i]!=0)
            diks[0]=i;
*/
        if ( FAILED(hr) )
            return hr;
    }

    return S_OK;
}



//-----------------------------------------------------------------------------
// Function: UpdateInputState
//
// Description:
//      Get the joystick input device's state.
//
//-----------------------------------------------------------------------------
HRESULT __cdecl UpdateInputStateJoystick(DIJOYSTATE *js)
{
    if (NULL != g_pJoystick)
    {
        HRESULT hr;

        hr = DIERR_INPUTLOST;

        // if input is lost then acquire and keep trying
        while ( DIERR_INPUTLOST == hr )
        {
            // poll the joystick to read the current state
            hr = IDirectInputDevice2_Poll(g_pJoystickDevice2);
            if ( FAILED(hr) )
                return NULL;

            // get the input's device state, and put the state in dims
            hr = IDirectInputDevice_GetDeviceState(g_pJoystick, sizeof(DIJOYSTATE), js );

            if ( hr == DIERR_INPUTLOST )
            {
                // DirectInput is telling us that the input stream has
                // been interrupted.  We aren't tracking any state
                // between polls, so we don't have any special reset
                // that needs to be done.  We just re-acquire and
                // try again.
                hr = IDirectInputDevice_Acquire(g_pJoystick);
                if ( FAILED(hr) )
                    return hr;
            }
        }
        return hr;
    }

    return -1;
}





//-----------------------------------------------------------------------------
// Function: FreeDirectInput
//
// Description:
//      Initialize the DirectInput variables.
//
//-----------------------------------------------------------------------------
HRESULT __cdecl FreeDirectInput()
{
    // Unacquire and release any DirectInputDevice objects.
    if (NULL != g_pMouse)
    {
        // Unacquire the device one last time just in case
        // the app tried to exit while the device is still acquired.
        IDirectInputDevice_Unacquire(g_pMouse);
        IDirectInputDevice_Release(g_pMouse);
        g_pMouse = NULL;
    }

    if (NULL != g_pKeyboard)
    {
        // Unacquire the device one last time just in case
        // the app tried to exit while the device is still acquired.
        IDirectInputDevice_Unacquire(g_pKeyboard);
        IDirectInputDevice_Release(g_pKeyboard);
        g_pKeyboard = NULL;
    }

    if (NULL != g_pJoystick)
    {
        // Unacquire the device one last time just in case
        // the app tried to exit while the device is still acquired.
        IDirectInputDevice_Unacquire(g_pJoystick);
        IDirectInput_Release(g_pJoystick);
        g_pJoystick = NULL;
    }

    if (NULL != g_pJoystickDevice2)
    {
        IDirectInput_Release(g_pJoystickDevice2);
        g_pJoystickDevice2 = NULL;
    }


    // Release any DirectInput objects.
    if (NULL != g_pDI)
    {
        IDirectInput_Release(g_pDI);
        g_pDI = NULL;
    }

    return S_OK;
}