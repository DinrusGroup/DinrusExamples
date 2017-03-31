@cls
ruladaex
del build\*.exe
rmdir .\build

dmd -release  beginner.d -L/exet:nt/su:windows:4.0
dmd -release  charformat -L/exet:nt/su:windows:4.0
dmd -release  client -L/exet:nt/su:windows:4.0
dmd -release  combo.d -L/exet:nt/su:windows:4.0
dmd -release  dnote dnote.res -L/exet:nt/su:windows:4.0
dmd -release  draw -L/exet:nt/su:windows:4.0
dmd -release  drop -L/exet:nt/su:windows:4.0
dmd -release  droplist -L/exet:nt/su:windows:4.0
dmd -release  helloworld -L/exet:nt/su:windows:4.0
dmd -release  invoke -L/exet:nt/su:windows:4.0
dmd -release  listbox -L/exet:nt/su:windows:4.0
dmd -release  listview -L/exet:nt/su:windows:4.0
dmd -release  mdi -L/exet:nt/su:windows:4.0
dmd -release  paint -L/exet:nt/su:windows:4.0
dmd -release  pictureviewer.d -L/exet:nt/su:windows:4.0
dmd -release  rich -L/exet:nt/su:windows:4.0
dmd -release  rps -L/exet:nt/su:windows:4.0
dmd -release  rps_server ws2_32.lib
dmd -release  shortcut.d -L/exet:nt/su:windows:4.0
dmd -release  tabs -L/exet:nt/su:windows:4.0
dmd -release  tip -L/exet:nt/su:windows:4.0
dmd -release  tiplist -L/exet:nt/su:windows:4.0
dmd -release  tray tray.res -L/exet:nt/su:windows:4.0
dmd -release  treeview.d -L/exet:nt/su:windows:4.0
dmd -release  progress -L/exet:nt/su:windows:4.0
dmd -release  rctest rctest.res -L/exet:nt/su:windows:4.0
dmd -release  dirlist -L/exet:nt/su:windows:4.0
dmd -release  filedrop -L/exet:nt/su:windows:4.0
dmd -release  scroller -L/exet:nt/su:windows:4.0
dmd -release  regextester -L/exet:nt/su:windows:4.0
dmd -release  listviewdirsort -L/exet:nt/su:windows:4.0
dmd -release  status -L/exet:nt/su:windows:4.0
dmd -release  dflhtmlget -L/exet:nt/su:windows:4.0


dmd -debug  -ofbeginner_debug.exe beginner.d -L/exet:nt/su:windows:4.0
dmd -debug  -ofcharformat_debug.exe charformat -L/exet:nt/su:windows:4.0
dmd -debug  -ofclient_debug.exe client -L/exet:nt/su:windows:4.0
dmd -debug  -ofcombo_debug.exe combo.d -L/exet:nt/su:windows:4.0
dmd -debug  -ofdnote_debug.exe dnote dnote.res -L/exet:nt/su:windows:4.0
dmd -debug  -ofdraw_debug.exe draw -L/exet:nt/su:windows:4.0
dmd -debug  -ofdrop_debug.exe drop -L/exet:nt/su:windows:4.0
dmd -debug  -ofdroplist_debug.exe droplist -L/exet:nt/su:windows:4.0
dmd -debug  -ofhelloworld_debug.exe helloworld -L/exet:nt/su:windows:4.0
dmd -debug  -ofinvoke_debug.exe invoke -L/exet:nt/su:windows:4.0
dmd -debug  -oflistbox_debug.exe listbox -L/exet:nt/su:windows:4.0
dmd -debug  -oflistview_debug.exe listview -L/exet:nt/su:windows:4.0
dmd -debug  -ofmdi_debug.exe mdi -L/exet:nt/su:windows:4.0
dmd -debug  -ofpaint_debug.exe paint -L/exet:nt/su:windows:4.0
dmd -debug  -ofpictureviewer_debug.exe pictureviewer.d -L/exet:nt/su:windows:4.0
dmd -debug  -ofrich_debug.exe rich -L/exet:nt/su:windows:4.0
dmd -debug  -ofrps_debug.exe rps -L/exet:nt/su:windows:4.0
dmd -debug  -ofrps_server_debug.exe rps_server ws2_32.lib
dmd -debug  -ofshortcut_debug.exe shortcut.d -L/exet:nt/su:windows:4.0
dmd -debug  -oftabs_debug.exe tabs -L/exet:nt/su:windows:4.0
dmd -debug  -oftip_debug.exe tip -L/exet:nt/su:windows:4.0
dmd -debug  -oftiplist_debug.exe tiplist -L/exet:nt/su:windows:4.0
dmd -debug  -oftray_debug.exe tray tray.res -L/exet:nt/su:windows:4.0
dmd -debug  -oftreeview_debug.exe treeview.d -L/exet:nt/su:windows:4.0
dmd -debug  -ofprogress_debug.exe progress -L/exet:nt/su:windows:4.0
dmd -debug  -ofrctest_debug.exe rctest rctest.res -L/exet:nt/su:windows:4.0
dmd -debug  -ofdirlist_debug.exe dirlist -L/exet:nt/su:windows:4.0
dmd -debug  -offiledrop_debug.exe filedrop -L/exet:nt/su:windows:4.0
dmd -debug  -ofscroller_debug.exe scroller -L/exet:nt/su:windows:4.0
dmd -debug  -ofregextester_debug.exe regextester -L/exet:nt/su:windows:4.0
dmd -debug  -oflistviewdirsort_debug.exe listviewdirsort -L/exet:nt/su:windows:4.0
dmd -debug  -ofstatus_debug.exe status -L/exet:nt/su:windows:4.0
dmd -debug  -ofdflhtmlget_debug.exe dflhtmlget -L/exet:nt/su:windows:4.0

@del *.obj *.map

mkdir .\build
copy *.exe /b .\build /b
del *.exe
dinrus