#!/usr/bin/env wolframscript
<<PlotGrid`; 
<<cmdline`opt`;
<<filestruct`;
<<QSF`;
<<MaTeX`;

PrettyPlots[]; 

(* This will not be necessary in next version --> *)
WavelengthFromPath:=Quantity[ToExpression[StringExtract[#,"nm_"->2,"/"->1]],"nm"]&;
PeriodFromPath:=PeriodFromWavelength[WavelengthFromPath[#]]&;
FWHMCyclesFromPath:=ToExpression[StringExtract[#,"fwhm_cycles_"->2,"/"->1]]&;

Enrich[hd_,data_]:={
  "cycles"->hd["tmax"]/PeriodFromPath[hd["path"]],
  "fwhm"->FWHMCyclesFromPath[hd["path"]],
  "period"->PeriodFromPath[hd["path"]],
  "TimeUnit"->"[%]",
  "DataUnit"->""
};
skip775nm:=Select[#,Not[StringContainsQ[#,"nm_775"]]&]&;
(* fileStruct=ParsePattern[
  "Results/model_*/flux_quiver_ratio_****/nm_***/fwhm_cycles_**/phase_*****/RE.dat",
  "ParseFilter"->skip775nm];

processed=StructProcess[fileStruct, "CacheDir"->"/tmp/mmac2/flx/",
"Operations"->{"~/Dropbox/NSDI-paper/"
  ,"FileFormat"->"pdf"
  ,EnrichMetadata->Enrich
  (* ,"ActOn"->{"N2S"} *)
  ,5->DataMerge[Mean,FluxDataQ]@*FLXLoad
  ,"GaussianBlurRadius"->20
  ,4->DataMap[GaussianFilterOpt,FluxDataQ]@*DataMap[Downsample[#,2]&,All]
  
  ,DataRange->{0,"cycles"}
  ,PlotRange->{{("cycles"-4)/2-("fwhm"*0.35),("cycles"-4)/2+("fwhm"*0.72)},Full}
  (* ,GridLines->Automatic,GridLinesStyle->Directive[Gray,Dashed] *)
  ,FrameLabel->{
    {None,HoldForm@MaTeX[LatexDataLabels["DataLabel"],Magnification->1.2]},
    {HoldForm["time""TimeUnit"], None}}
  ,LegendLabel->Placed["Wavelength",Before]
  ,LegendTranslate->(RemoveJunk[#/.Key[c___]->Quantity[ExtractNumbers[c],"nm"]]&)
  ,{"pop_rel/0.5-2.0/"
    ,4->DataMap[TimeSeries[#,{1.0/Length[#]}]&,FluxDataQ]
    ,4->DataMerge[(-Differences[#])&,FluxDataQ]
    ,3->DataMap[(First[#]["Values"])&,FluxDataQ]
    ,1->DataMap[Accumulate,FluxDataQ]
    ,1->GlobalOpt["Scale",StandardDeviation,FluxDataQ]
    ,1->DataMap[(1000.0* #/COptionValue["Scale"])&,FluxDataQ]
    ,3->DataPlots[{"A","N2S","*2D_SYM","*2D_ASYM","*2D"}]
    ,2->Expo@*DataPlotGrid
  }
}]; *)

ClearOpts[];
fileStruct=ParsePattern[
  "Results/model_*/flux_quiver_ratio_0.500000/nm_3100/fwhm_cycles_**/phase_***/RE.dat",
  "ParseFilter"->skip775nm];

processed=StructProcess[fileStruct, "CacheDir"->"/tmp/fqr0.5/",
"Operations"->{"~/Dropbox/NSDI-paper/flux_quiver_ratio_0.5/"
  ,"FileFormat"->"pdf"
  ,EnrichMetadata->Enrich
  (* ,"ActOn"->{"N2S"} *)
  ,3->DataMerge[Mean,FluxDataQ]@*FLXLoad
  ,"GaussianBlurRadius"->30
  ,2->DataMap[GaussianFilterOpt,FluxDataQ]@*DataMap[Downsample[#,4]&,All]
  
  ,DataRange->{0,QuantityMagnitude["tmax"/"fwhm"/("period"*3.3)]}
  (* ,PlotRange->{{("cycles"-4)/2-("fwhm"*0.35),("cycles"-4)/2+("fwhm"*0.72)}/"cycles",Full} *)
  ,PlotRange->{{0.4,1.0},Full}
  (* ,PlotRange->{{0,("fwhm"*1.5)/"cycles"},Full} *)
  (* ,GridLines->Automatic,GridLinesStyle->Directive[Gray,Dashed] *)
  ,FrameLabel->{
    {None,HoldForm@MaTeX[LatexDataLabels["DataLabel"],Magnification->1.2]},
    {HoldForm["rescaled pulse time""TimeUnit"], None}}
  ,LegendLabel->Placed["FWHM [cycles]",Before]
  ,LegendTranslate->(RemoveJunk[#/.Key[c___]->Round[ExtractNumbers[c],0.1]]&)
  ,{"flx/"
    ,1->GlobalOpt["Scale",StandardDeviation,FluxDataQ]
    ,1->DataMap[(1000.0* #/COptionValue["Scale"])&,FluxDataQ]
    ,2->DataPlots[{"A","N2S","N2D_SYM","N2D_ASYM","S2D_SYM","S2D_ASYM", "*2D_SYM", "*2D_ASYM"}]
    ,2->Expo@*DataPlotGrid}
  ,{"pop/"
    ,1->DataMap[Accumulate,FluxDataQ]
    ,1->GlobalOpt["Scale",StandardDeviation,FluxDataQ]
    ,1->DataMap[(1000.0* #/COptionValue["Scale"])&,FluxDataQ]
    ,2->DataPlots[{"A","N2*","*2S","*2D_SYM","*2D_ASYM","*2D"}]
    ,2->Expo@*DataPlotGrid
  }
}];

ClearOpts[];
fileStruct=ParsePattern[
  "Results/model_*/flux_quiver_ratio_2.000000/nm_3100/fwhm_cycles_**/phase_***/RE.dat",
  "ParseFilter"->skip775nm];

processed=StructProcess[fileStruct, "CacheDir"->"/tmp/fqr2.0/",
"Operations"->{"~/Dropbox/NSDI-paper/flux_quiver_ratio_2.0/"
  ,"FileFormat"->"pdf"
  ,EnrichMetadata->Enrich
  (* ,"ActOn"->{"N2S"} *)
  ,3->DataMerge[Mean,FluxDataQ]@*FLXLoad
  ,"GaussianBlurRadius"->30
  ,2->DataMap[GaussianFilterOpt,FluxDataQ]@*DataMap[Downsample[#,4]&,All]
  
  ,DataRange->{0,QuantityMagnitude["tmax"/"fwhm"/("period"*3.3)]}
  (* ,PlotRange->{{("cycles"-4)/2-("fwhm"*0.35),("cycles"-4)/2+("fwhm"*0.72)}/"cycles",Full} *)
  ,PlotRange->{{0.4,1.0},Full}
  (* ,PlotRange->{{0,("fwhm"*1.5)/"cycles"},Full} *)
  (* ,GridLines->Automatic,GridLinesStyle->Directive[Gray,Dashed] *)
  ,FrameLabel->{
    {None,HoldForm@MaTeX[LatexDataLabels["DataLabel"],Magnification->1.2]},
    {HoldForm["rescaled pulse time""TimeUnit"], None}}
  ,LegendLabel->Placed["FWHM [cycles]",Before]
  ,LegendTranslate->(RemoveJunk[#/.Key[c___]->Round[ExtractNumbers[c],0.1]]&)
  ,{"flx/"
    ,1->GlobalOpt["Scale",StandardDeviation,FluxDataQ]
    ,1->DataMap[(1000.0* #/COptionValue["Scale"])&,FluxDataQ]
    ,2->DataPlots[{"A","N2S","N2D_SYM","N2D_ASYM","S2D_SYM","S2D_ASYM", "*2D_SYM", "*2D_ASYM"}]
    ,2->Expo@*DataPlotGrid}
  ,{"pop/"
    ,1->DataMap[Accumulate,FluxDataQ]
    ,1->GlobalOpt["Scale",StandardDeviation,FluxDataQ]
    ,1->DataMap[(1000.0* #/COptionValue["Scale"])&,FluxDataQ]
    ,2->DataPlots[{"A","N2*","*2S","*2D_SYM","*2D_ASYM","*2D"}]
    ,2->Expo@*DataPlotGrid
  }
}];