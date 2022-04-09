#!/usr/bin/env wolframscript
<<PlotGrid`; 
<<cmdline`opt`;
<<filestruct`;
<<QSF`;
<<MaTeX`;

fileStruct=ParsePattern[
  "Results/model_*/flux_quiver_ratio_1.000000/nm_***/fwhm_cycles_**/phase_0.5****/RE.dat",
  "ParseFilter"->Identity];

PrettyPlots[]; 

(* This will not be necessary in next version --> *)
WavelengthFromPath:=Quantity[ToExpression[StringExtract[#,"nm_"->2,"/"->1]],"nm"]&;
PeriodFromPath:=PeriodFromWavelength[WavelengthFromPath[#]]&;
FWHMCyclesFromPath:=ToExpression[StringExtract[#,"fwhm_cycles_"->2,"/"->1]]&;

Enrich[hd_,data_]:={
  "cycles"->hd["tmax"]/PeriodFromPath[hd["path"]],
  "fwhm"->FWHMCyclesFromPath[hd["path"]],
  "TimeUnit"->"[cycles]",
  "DataUnit"->""
};

processed=StructProcess[fileStruct, "CacheDir"->"/tmp/mmac/flx/",
"Operations"->{"~/Dropbox/NSDI-paper/"
  ,"FileFormat"->"pdf"
  ,EnrichMetadata->Enrich
  (* ,"ActOn"->{"N2S"} *)
  ,1->FLXLoad
  ,3->DataMerge[Mean,FluxDataQ]
  ,1->DataMap[Downsample[#,2]&,All]
  ,"GaussianBlurRadius"->20
  ,1->DataMap[GaussianFilterOpt,FluxDataQ]
  ,0->GlobalOpt["Scale",StandardDeviation,FluxDataQ]
  ,0->DataMap[(#/COptionValue["Scale"])&,FluxDataQ]
  ,DataRange->{0,"cycles"}
  ,PlotRange->{{("cycles"-4)/2-("fwhm"*0.35),("cycles"-4)/2+("fwhm"*0.72)},Full}
  ,GridLines->Automatic,GridLinesStyle->Directive[Gray,Dashed]
  ,FrameLabel->{
    {None,HoldForm@MaTeX[LatexDataLabels["DataLabel"],Magnification->1.2]},
    {HoldForm["time""TimeUnit"], None}}
  ,LegendLabel->Placed["Wavelength",Before]
  ,LegendTranslate->(RemoveJunk[#/.Key[c___]->Quantity[ExtractNumbers[c],"nm"]]&)
  ,{"flx/"
    ,2->DataPlots[{"A","N2S","N2D_SYM","N2D_ASYM","S2D_SYM","S2D_ASYM","*2S","*2D"}]
    ,1->Expo@*DataPlotGrid}
  ,{"pop/"
    ,1->DataMap[Accumulate,FluxDataQ]
    ,2->DataPlots[{"A","N2S","N2D_SYM","N2D_ASYM","S2D_SYM","S2D_ASYM","*2S","*2D"}]
    ,1->Expo@*DataPlotGrid
  }
}];