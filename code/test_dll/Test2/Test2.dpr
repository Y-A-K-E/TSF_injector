library Test2;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  System.DateUtils,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  HookUtils in 'HookSource\HookUtils.pas';

//关闭日志显示
{$DEFINE OFFLOG}

{$R *.res}
type
  TMainWindow = packed record
    ProcessID: THandle;
    MainWindow: THandle;
  end;
  PMainWindow =^ TMainWindow;


type
   PEnumInfo = ^TEnumInfo;
   TEnumInfo = record
      ProcessID: DWORD;
      HWND: THandle;
   end;

var


P_hwd:HWND;   //目标窗口顶级句柄
win_num:integer;  //全局累加器.仅用于 改目标程序标题.
  hButton    : HWND;
  hFontButton: HWND;
OldAppProc: Pointer;

//计时器
timer_ptr_5:UIntPtr;
timer_ptr_4:UIntPtr;
timer_ptr_3:UIntPtr;
timer_ptr_2:UIntPtr;
timer_ptr_1:UIntPtr;
timer_ptr_0:UIntPtr;

fun_var_pid:DWORD;
fun_var_hwd:HWND;

MainHook:Uint64;


GetLocalTimeNext:procedure(var lpSystemTime: TSystemTime); stdcall;

MessageBoxNext: function (hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall;





procedure writeWorkLog(sqlstr: string);
var
  filev: TextFile;
  ss: string;
begin

{$IFDEF OFFLOG}
exit;
{$ENDIF}

  sqlstr:=DateTimeToStr(Now)+' Log: '+sqlstr;

  ss:=GetEnvironmentVariable('USERPROFILE') + '\Desktop\DLLRunLog.txt';

  if FileExists(ss) then
  begin
    AssignFile(filev, ss);
    append(filev);
    writeln(filev, sqlstr);
  end else begin
    AssignFile(filev, ss);
    ReWrite(filev);
    writeln(filev, sqlstr);
  end;

  CloseFile(filev);
end;







function getparenthwd(var tmpHWND:HWND):DWORD;
var
tmp:HWND;
tmp2:HWND;
begin
    tmp2:=0;
    tmp:=GetParent(tmpHWND);


     while tmp >0 do
     begin
         tmp:=getparenthwd(tmp);
     end;
    if tmp <> 0  then tmp2:=tmp;

    Result:=tmp2;
end;


   function G_EnumWindowsProc(Wnd: HWND; var EI: TEnumInfo): Bool; stdcall;
   var
      PID: DWORD;
  h: THandle;
  arr: array[0..254] of Char;
  tmpIsFlag:Boolean;
  tmpThreadID:THandle;
   begin
      Result := True;
      GetWindowThreadProcessID(Wnd, @PID);


Result := (PID <> EI.ProcessID) or
(not IsWindowVisible(WND)) or
(not IsWindowEnabled(WND));

      if not Result then
        begin
          h := getparenthwd(WND);


          if h>0 then
          begin
            EI.HWND := h;
          end
            else
            begin
              EI.HWND := WND;
            end;
        end;



//      Result := (PID <> EI.ProcessID) or
//         (not IsWindowVisible(WND)) or
//         (not IsWindowEnabled(WND));
//      if not Result then EI.HWND := WND; //break on return FALSE
   end;

function G_FindMainWindow(PID: DWORD): DWORD;
   var
      EI: TEnumInfo;
   begin
      EI.ProcessID := PID;
      EI.HWND := 0;
      EnumWindows(@G_EnumWindowsProc, Integer(@EI));
      Result := EI.HWND;
   end;


//https://codeoncode.blogspot.com/2016/12/get-processid-by-programname-include.html
function GetHWndByPID(const hPID: THandle): THandle;
begin
   if hPID <> 0 then
      Result := G_FindMainWindow(hPID)
   else
      Result := 0;
end;




function _IsMainWindow(AHandle: HWND): BOOL;
begin
  Result :=(GetWindow(AHandle, GW_OWNER) = 0) and (IsWindowVisible(AHandle));
end;{ IsMainWindow }

function _fFindMainWindow(tmphWnd: DWORD; lParam: integer=0): BOOL; stdcall;
var
  vProcessID: DWORD;
begin
  GetWindowThreadProcessId(tmphWnd, addr(vProcessID));
  //and IsMainWindow(hWnd)

  if (fun_var_pid = vProcessID) and _IsMainWindow(tmphWnd) then
  begin
    //OutputDebugString(pwidechar('入口pid: '+inttostr(fun_var_pid) + ' 枚举句柄: ' + inttostr(tmphWnd)));
    fun_var_hwd := tmphWnd;
    Result := false;
  end else Result := True;
end;

//https://www.iteye.com/blog/huobengle-1382392
//判断是否主窗口
//这个也不知道原作者是谁,我就看好多地方抄来抄去没有原作者.
function FindMainWindow(AProcessID: DWORD): THandle;
begin
  fun_var_pid:= AProcessID;
  fun_var_hwd:= 0 ;
  EnumWindows(@_fFindMainWindow,integer(0));
  Result := fun_var_hwd;
end;{ FindMainWindow }















//改变目标程序标题
//将一个全局累加器的值显示在目标窗口的标题上
procedure SetWinTextTimerProc(hwnd:HWND;uMsg,idEvent:UINT;dwTime:DWORD); stdcall;
begin
    inc(win_num);
    SetWindowText(P_hwd,'被DLL修改了窗口名--'+ inttostr(win_num));
end;

function  Change_From_Text():integer;stdcall;
begin
    timer_ptr_0:=SetTimer(P_hwd, 0, 1000, @SetWinTextTimerProc);
    Result:=0;
end;




//按HOME激活函数,一次性
//通过GetAsyncKeyState判断按键是否按下
//这个体验不是很好
procedure HomeFunTimerProc(hwnd:HWND;uMsg,idEvent:UINT;dwTime:DWORD); stdcall;
begin
  if GetAsyncKeyState(Vk_HOME)<> 0 then
  begin
    //KillTimer(P_hwd,2);  //如果只需要响应一次就就需要关闭计时器
    showmessage('按下了HOME');
  end;
end;

function  Home_KEY_FUN_1():integer;stdcall;
begin
    timer_ptr_2:= SetTimer(P_hwd, 2, 500, @HomeFunTimerProc);
    Result:=0;
end;















//在目标程序上打开一个新窗口
procedure OpenNewWinTimerProc(hwnd:HWND;uMsg,idEvent:UINT;dwTime:DWORD); stdcall;
begin
  KillTimer(P_hwd,1); //关闭计时器,防止反复打开
  if not assigned(Form1) then
  begin
    Form1:=TForm1.Create(nil);
  end;
  Form1.ShowModal;
end;

function OpenFormWindow():integer;stdcall;
begin
  timer_ptr_1:=SetTimer(P_hwd, 1, 1000, @OpenNewWinTimerProc);
  Result:=0;
end;







//回调
procedure  GetLocalTimeCallBack (var lpSystemTime: TSystemTime); stdcall;
begin
    //原始函数备胎指针
    GetLocalTimeNext(lpSystemTime);

    //将日期改为 1999/09/09
    lpSystemTime.wYear:= 1999;
    lpSystemTime.wMonth:= 09;
    lpSystemTime.wDay := 09;


    //lpSystemTime.wHour:=09;

end;



function Hook_time_1999_09_09():integer;stdcall;
begin

  //hook api
  if not Assigned(GetLocalTimeNext) then
  begin
    HookProc(kernel32, 'GetLocalTime', @GetLocalTimeCallBack, @GetLocalTimeNext);
  end
  else
  begin
    //ShowMessage('钩过了');
  end;

  Result:=0;
end;




function MessageBoxCallBack(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall;
var
  S: string;
begin
    S := '现在原来你消息函数被Hook了.'+#13#10 + '你原来的消息是:'+ #13#10#13#10
      + lpText;
  Result := MessageBoxNext(hWnd, PChar(S), lpCaption, uType);
end;



function Hook_MessageBox():integer;stdcall;
const
{$IFDEF UNICODE}
  MessageBoxProcName = 'MessageBoxW';
{$ELSE}
  MessageBoxProcName = 'MessageBoxA';
{$ENDIF}
begin

  //hook api
  if not Assigned(MessageBoxNext) then
  begin
    HookProc(user32,MessageBoxProcName, @MessageBoxCallBack, @MessageBoxNext);
  end
  else
  begin
    //ShowMessage('钩过了');
  end;

  Result:=0;
end;



//控件窗口句柄 转vcl控件实例
//https://www.cnblogs.com/devcjq/articles/7482467.html
function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;
type
  PObjectInstance = ^TObjectInstance;

  TObjectInstance = packed record
    Code: Byte;            { 短跳转 $E8 }
    Offset: Integer;       { CalcJmpOffset(Instance, @Block^.Code); }
    Next: PObjectInstance; { MainWndProc 地址 }
    Self: Pointer;         { 控件对象地址 }
  end;
var
  wc: PObjectInstance;
begin
  Result := nil;
  wc     := Pointer(GetWindowLong(hWnd, GWL_WNDPROC));
  if wc <> nil then
  begin
    Result := wc.Self;
  end;
end;







procedure CustomButtonClick();
begin
  showmessage('DLL创建按钮被响应');
end;


//代码来自
//https://github.com/xieyunc/dmtjsglxt/blob/5160838122879e9773b30302442e5843724e9b90/SASWinHook.dpr

function HookProc(hHandle: THandle; uMsg: Cardinal;
  wParam, lParam: Integer): LRESULT; stdcall;
var K, C: Word;  // wndproc
begin

//  if uMsg > 0 then
//  begin
//     writeWorkLog('创建按钮:Hook消息回调msg:'+inttostr(uMsg) +'Wp:' + inttostr( wParam) + 'Lp:' +inttostr( lParam ) );
//  end;

  if uMsg = WM_COMMAND then
  begin
    if lParam = hButton then
    begin
        CustomButtonClick();
    end;

  end;


//  if uMsg = WM_HOTKEY then
//     begin
//        K := HIWORD(lParam);
//        C := LOWORD(lParam);
//        // press Ctrl + Alt + Del
//        if (C and VK_CONTROL<>0) and (C and VK_MENU <>0) and ( K = VK_Delete)
//           then Exit;   // disable Ctrl + Alt + Del
//     end;
  Result := CallWindowProc(OldAppProc, hHandle,uMsg, wParam, lParam);
end;

//在目标窗口上动态创建一个按钮
//响应按钮事件需要hook消息
function New_Button():integer;stdcall;
var
R: TRect;
new_top:integer;
new_left:integer;
begin
  //获取目标窗口的大小
  GetWindowRect(P_hwd, R);

   //R.Right - R.Left   = 窗口宽
   // R.Bottom - R.Top  = 窗口高
   // 按钮 宽 150   高30

   // 窗口宽 - 按钮宽(150) / 2 得到按钮在窗口中间的位置
  new_left:= trunc( (( R.Right - R.Left) - 150) / 2 ) ;

  //按钮在窗口底部30位置的地方
  // 去掉 15 窗口标题高度
  // 去掉 30 按钮本身高度
  new_top:= (R.Bottom - R.Top) -15  -30 -30 ;

  hFontButton := CreateFont(-14,0,0,0,0,0,0,0,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,VARIABLE_PITCH or FF_SWISS,'Tahoma');

  writeWorkLog('创建按钮:字体句柄'+inttostr(hFontButton));

  hButton:=CreateWindow('Button','DLL新建的按钮', WS_VISIBLE or WS_CHILD or BS_PUSHBUTTON or BS_TEXT, new_left,new_top,150,30,P_hwd,0,hInstance,nil);

  writeWorkLog('创建按钮:按钮句柄'+inttostr(hButton));

  SendMessage(hButton,WM_SETFONT,hFontButton,0);

  OldAppProc := Pointer(GetWindowLong(P_hwd, GWL_WNDPROC));
  SetWindowLong(P_hwd, GWL_WNDPROC, Cardinal(@HookProc));

  writeWorkLog('创建按钮:Hook OldAppProc值'+inttostr(uint64(OldAppProc)));

  Result:=0;
end;





//入口函数处理
procedure DLLEntryPoint(Reason: integer);
begin
  case Reason of
    DLL_PROCESS_ATTACH:
      begin
        writeWorkLog('------------------------------');


        {$IF Defined(CPUX86)}
        writeWorkLog('入口:当前为X86');
        {$ELSEIF Defined(CPUX64)}
        writeWorkLog('入口:当前为X64');
        {$IFEND}

        //获取目标程序顶级窗口句柄
        P_hwd:=GetHWndByPID(GetCurrentProcessId);

        writeWorkLog('获取顶级窗口句柄:' +  inttostr(P_hwd));
      end;
    DLL_PROCESS_DETACH:
      begin
          //反hook
          if Assigned(GetLocalTimeNext) then
          begin
               UnHookProc(@GetLocalTimeNext);
          end;

         if Assigned(OldAppProc) then
            SetWindowLong(P_hwd, GWL_WNDPROC, LongInt(OldAppProc));
         OldAppProc := nil;

          KillTimer(P_hwd,0);
          KillTimer(P_hwd,1);
          KillTimer(P_hwd,2);
          KillTimer(P_hwd,4);

          writeWorkLog('结束DLL');
      end;
  end;
end;


exports
OpenFormWindow, {打开一个新窗口}
Change_From_Text, {修改窗口标题}
HOME_KEY_FUN_1,  {响应HOME按键函数}
Hook_MessageBox,  {Hook MessageBox}
//Hook_time_1999_09_09,  {用HOOK修改时间}
New_Button;


begin
   //重定义入口指针

  DllProc := @DLLEntryPoint;
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
