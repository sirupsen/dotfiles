@echo off
REM Run gvim in easy mode, set up for outlining.

REM Where Vim got installed to
set VIM=c:\vim
set VIMVERSION=62

REM where TVO got unpacked to
set TVO=%VIM%\vimfiles
%VIM%\vim%VIMVERSION%\gvim.exe -y -u %TVO%\easy.vimrc -U %TVO%\easy.gvimrc %*
