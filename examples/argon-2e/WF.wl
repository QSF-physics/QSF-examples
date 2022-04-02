#!/usr/bin/env wolframscript
<<"PlotGrid`";
<<"cmdline`opt`";
<<"filestruct`";
Needs["QSF`"];
Needs["QSF`wf`"];
Needs["QSF`StyleUtils`"];
<<MaTeX`;
Off[Syntax::stresc];
(* Number of stars correspond to the hierarchy (nested Associations) level created by ParsePattern*)
(* ParseFilter can be any kind of string validation, Identity passes through everything,
WFFileNameQ and DataFileNameQ are predefined in the QSF`wf and QSF`data packages*)
fileStruct=ParsePattern[
"Results/model_*/flux_quiver_ratio_2.000000/nm_**/fwhm_cycles_***/phase_****/momenta_repP.psi*****"
,"ParseFilter"->Identity];

PrettyPlots[]; (* Activates LaTeX fonts *)
rng=4; (* Common options *)
common2Dopts=Sequence[FrameTicks->{{True, True},{True, None}}
,FrameLabel->{MaTeX["p_{2}", Magnification -> 1.5],MaTeX["p_{1}", Magnification -> 1.5]}
,"GaussianBlurRadius"->0.05];
common1Dopts=Sequence[LegendLabel->"label"
      ,PlotRange->{{0,rng*Sqrt[2]/2/2},Full},Filling->Axis
      ,FrameLabel->{MaTeX["p^{corr}_{\perp}", Magnification -> 1.5],"[au]"}
      ,FillingStyle -> Directive[Opacity[0.1]]
      ,GridLines->{Automatic,Range[0, 3, 0.5]}
      ,GridLinesStyle -> Directive[Gray, Dashed]
      ,AspectRatio->1/2
      ,"LegendLabels"->(Round[ExtractNumbers[#],0.1] &)
      ,"GridTranspose"->False
      ,"GaussianBlurRadius"->0.1
      ,"PlotGridPadding"->101];

(* Processes nested Association's produced by ParsePattern. Input "Operations" can be:
- Lists [{...}]: To scope operations, i.e., only operations from parent lists will be applied
- String ["sub/path"]: which will be interpreted as output path (or subpath if found in nested list)
- Option Rules ["name"->value] will be piped to operations which after them, till the end of the current list
- Functions: [FunctionName] applied to the hierarchy but not modyfing it
And the most important:
- Hierarchy Rules [levelIndex->FunctionName]: Represent functions applied to the hierarchy at levelIndex *)
processed=StructProcess[fileStruct, 
"Operations"->
{"~/Dropbox/NSDI-paper/"
  ,"FileFormat"->"pdf"
  ,"TrimMarginsPercent"->0.19
  ,"WFMaskEdgeAtRatio"->0.7
  (* ,"LeafPath"->"path/filename"  *)
  ,3 ->TrimMargins@*Average@*RemoveBoundedPart@*WFLoad
  ,{"wf"    
    ,{"2d/full/",common2Dopts
      ,PlotRange->{{-rng,rng},{-rng,rng},Full}
      ,1->WFPlot@*GaussianBlur,1->WFExport
      ,2->WFGrid,2->WFExport
    }
    ,{"1d_transverse_diag/full",common1Dopts
      ,2->WFGrid@*WFCombine@*GaussianBlur@*TransverseDiagSum
      ,0->WFExport
    }
    ,1->MergeOrthants
    ,{"2d/orthants_merged/",common2Dopts
      ,PlotRange->{{0,rng},{0,rng},Full}
      ,1->WFPlot@*GaussianBlur,1->WFExport
      ,2->WFGrid,2->WFExport
    }
    ,{"1d_transverse_diag/orthants_merged"
      ,common1Dopts
      ,2->WFGrid@*WFCombine@*GaussianBlur@*TransverseDiagSum
      ,0->WFExport
    }
  }
}];