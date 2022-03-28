#!/usr/bin/env wolframscript

(* << "ForScience`";
<< "ForScience`Util`";
<< "ForScience`PlotUtils`"; *)
<<"PlotGrid`";
<<"cmdline`opt`";
<<"filestruct`";
Needs["QSF`"];
Needs["QSF`wf`"];
Needs["QSF`styling`"];
<<MaTeX`;
(* Number of stars correspond to the hierarchy (nested Associations) level created by ParsePattern*)
(* ParseFilter can be any kind of string validation, Identity passes through everything,
WFFileNameQ and DataFileNameQ are predefined in the QSF`wf and QSF`data packages*)
fileStruct=ParsePattern[
"Results/model_*/flux_quiver_ratio_2.000000/nm_**/fwhm_cycles_***/phase_****/momenta_repP.psi*****"
,"ParseFilter"->Identity];

DP:=Print[ToString[#,InputForm]]&;
rng=4;

(* Processes nested Association's produced by ParsePattern. Input "Operations" can be:
- Lists [{...}]: To scope operations, i.e., only operations from parent lists will be applied
- String ["sub/path"]: which will be interpreted as output path (or subpath if found in nested list)
- Option Rules ["name"->value] will be piped to operations which after them, till the end of the current list
- Functions: [FunctionName] applied to the hierarchy but not modyfing it
And the most important:
- Hierarchy Rules [levelIndex->FunctionName]: Represent functions applied to the hierarchy at levelIndex *)
PrettyPlots[];
processed=StructProcess[fileStruct, 
"Operations"->
{
  "~/Projects/Quantum/NSDI-paper/"
  ,"FileFormat"->"pdf"
  ,"TrimMarginsPercent"->0.2
  ,"WFMaskEdgeAtRatio"->0.7
  (* ,"LeafPath"->"path/filename"  *)
  ,3 ->TrimMargins@*Average@*RemoveBoundedPart@*WFLoad
  (* ,PrettyPlots *)
  ,{
    "wf2d/full/"
    ,PlotRange->{{-rng,rng},{-rng,rng},Full}
    ,FrameTicks->{{True, True},{None, True}}
    ,{
      "blurred/"
      ,"GaussianBlurRadius"->0.05
      ,1->WFExport@*WFPlot@*GaussianBlur
    }
    ,1->WFExport@*WFPlot
  }
  ,1->MergeOrthants
  ,{
    {
      "wf2d/orthants_merged/"
      ,PlotRange->{{0,rng},{0,rng},Full}
      ,1->WFExport@*WFPlot
    }
    ,{
      "wf2d/orthants_merged_and_blured/"
      ,"GaussianBlurRadius"->0.05
      ,PlotRange->{{0,rng},{0,rng},Full}
      ,1->WFExport@*WFPlot@*GaussianBlur
    }
    ,{
      "wf1d/orthants_merged_and_blured_transverse_diag"
      ,LegendLabel->"label"
      ,PlotRange->{{0,rng*Sqrt[2]/2/2},Full}
      ,Filling->Axis
      ,FrameLabel->{MaTeX["p^{corr}_{\perp}", Magnification -> 1.5],"[au]"}
      ,FillingStyle -> Directive[Opacity[0.1]]
      ,GridLines->{Automatic,Range[0, 3, 0.5]}
      ,GridLinesStyle -> Directive[Gray, Dashed]
      ,AspectRatio->1/2
      ,"LegendLabels"->(Round[ExtractNumbers[#],0.1] &)
      ,"GridTranspose"->False
      ,"GaussianBlurRadius"->0.1
      ,"PlotGridPadding"->101
      ,2->WFCombine@*GaussianBlur@*TransverseDiagSum
      ,0 ->WFExport@*WFGrid
    }
  }
}];