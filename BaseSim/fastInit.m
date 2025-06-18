#clear all variables and start new
#if we need temp files, clean the tempdir here too.
clear all
close all
clc
cse=loadcase('V2G_DSYS.m');
opt=mpoption();
pret=runpf(cse,opt);

