#!/usr/bin/env wolframscript
<<"PlotGrid`"; 
<<"cmdline`opt`";
<<"filestruct`";
<< "QSF`";
(* Needs["QSF`flx`"]; *)
(* Needs["QSF`StyleUtils`"]; *)
(* Needs["QSF`DataAnalysis`"]; *)
(* <<MaTeX`; *)

fileStruct=ParsePattern[
"Results/model_*/flux_quiver_ratio_1.000000/nm_***/fwhm_cycles_**/phase_0.5****/RE.dat","ParseFilter"->Identity];

PrettyPlots[]; (* Activates LaTeX fonts *)

processed=StructProcess[fileStruct, "CacheDir"->"/tmp/mmac/flx/",
"Operations"->
{"~/Dropbox/NSDI-paper/"
  ,"FileFormat"->"pdf"
  (* ,"ActOn"->{"N2S"} *)
  ,3->Average[FluxDataQ]@*FLXLoad
  ,"GaussianBlurRadius"->200.1
  ,1->DataMap[GaussianBlur2,All]
  ,2->DataPlots[{"A","N2S","S2D_SYM", "N2D_ASYM"}]
  ,1->DataPlotGrid
  (* ,3->AverageFluxes *)
}];